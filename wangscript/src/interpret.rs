use crate::ast::{P, Stm, Stms, Atom, Ops, Expr, Args, Function};

use std::collections::HashMap;
use std::rc::Rc;
use std::cell::{RefCell, Ref, RefMut};
use std::io::{Read, Write};
use std::dbg;

pub struct Interpreter {
    table: SymbolTable,
}

impl Interpreter {
    pub(crate) fn new() -> Interpreter {
        let table = SymbolTable::new();
        table.env.borrow_mut().as_obj_mut().map(|map| {
            map.insert("node".into(), new_obj(Value::Function(Function {
                name: "node".into(),
                args: vec!["title".into()],
                instr: Stms(Vec::new()),
            })));
            map.insert("edge".into(), new_obj(Value::Function(Function {
                name: "edge".into(),
                args: vec!["node1".into(), "node2".into()],
                instr: Stms(Vec::new()),
            })));
            map
        }).expect("env is not an obj?!");
        Interpreter {
            table: table
        }
    }
    pub(crate) fn run_stm(&mut self, stm: &Stm) -> Result<(), ()> {
        match *stm {
            Stm::Block(ref stms) => self.run_stms(stms)?,
            Stm::Single(ref expr) => { self.eval_expr(expr)?; },
        }
        Ok(())
    }

    pub(crate) fn run_stms(&mut self, stms: &Stms) -> Result<(), ()> {
        for stm in stms.0.iter() {
            self.run_stm(stm)?;
        }
        Ok(())
    }

    fn eval_expr(&mut self, expr: &Expr) -> Result<Val, ()> {
        match *expr {
            Expr::Op(op, ref left, ref right) => self.apply_op(op, &*left.p, &*right.p),
            Expr::Atm(ref atom) => self.eval_atom(&*atom.p),
            Expr::Call(ref atom, ref args) => {
                match *self.eval_atom(&atom.p)?.take_obj()?.borrow() {
                    Value::Function(ref f) => {
                        let mut c_args = Vec::new();
                        for expr in &args.0 {
                            c_args.push(self.eval_expr(expr)?.take_obj()?);
                        }
                        self.eval_function(f, &c_args)
                    },
                    _ => Err(())
                }
            }, // TODO: evaluate this
        }
    }

    fn eval_atom(&mut self, atom: &Atom) -> Result<Val, ()> {
        match *atom {
            Atom::Integer(val) => Ok(Val::new(Value::Integer(val))),
            Atom::Str(ref val) => Ok(Val::new(Value::String(val.clone()))),
            Atom::Exp(ref expr) => self.eval_expr(&*expr.p),
            Atom::Ident(ref ident) => Ok(Val::Acc(self.table.env.clone(), ident.clone())),
        }
    }

    fn apply_op(&mut self, op: Ops, left: &Atom, right: &Expr) -> Result<Val, ()> {
        match op {
            Ops::Asg => {
                let left_res = self.eval_atom(left)?;
                let right_res = self.eval_expr(right)?;
                match left_res {
                    Val::Ptr(_) => Ok(right_res),
                    Val::Acc(ref rc, ref s) => {
                        rc.borrow_mut().as_obj_mut().ok_or(()).and_then(|map| {
                            map.insert(s.clone(), right_res.clone().take_obj()?);
                            Ok(Val::Ptr(right_res.take_obj()?))
                        })
                    },
                }
            }
            _ => Err(()) // TODO: Implement this
        }
    }

    fn eval_function(&mut self, f: &Function, args: &[Obj]) -> Result<Val, ()> {
        if args.len() != f.args.len() {
            return Err(())
        }
        match f.name.as_ref() {
            // Handle builtins
            "node" => self.eval_node_function(f, args),
            "edge" => self.eval_edge_function(f, args),
            _ => Err(()),
        }
    }

    fn eval_node_function(&mut self, _f: &Function, args: &[Obj]) -> Result<Val, ()> {
        if args.len() != 1 {
            panic!("node call with wrong number of arguments");
        }
        if let Value::String(..) = *args[0].borrow() {
        } else {
            return Err(())
        }
        let mut obj = HashMap::new();
        obj.insert("__class__".into(), new_obj(Value::String("__builtin_node__".into())));
        obj.insert("__sons__".into(), new_obj(Value::List(Vec::new())));
        obj.insert("title".into(), args[0].clone());
        Ok(Val::Ptr(new_obj(Value::Obj(obj))))
    }
    
    fn eval_edge_function(&mut self, _f: &Function, args: &[Obj]) -> Result<Val, ()> {
        if args.len() != 2 {
            panic!("edge call with wrong number of arguments");
        }
        if !is_node(&args[0]) || !is_node(&args[1]) {
            return Err(())
        }
        match *args[0].borrow_mut() {
            Value::Obj(ref mut map) => {
                map.get("__sons__".into())
                    .map(|x| x.borrow_mut())
                    .map(|mut x| match *x {
                        Value::List(ref mut sons) => {
                            sons.push(args[1].clone());
                        },
                        _ => (),
                    })
                    .ok_or(())?
            },
            _ => panic!("it is not an object ?!"),
        }
        Ok(Val::Ptr(none_obj()))
    }
    
    fn generate_code<W: Write>(&self, stream: &mut W) -> Result<(), ()> {
        stream.write_all(b"\\tikz ").map_err(|_| ())?;
        self.table.env.borrow()
                      .as_obj()
                      .ok_or(())
                      .and_then( |obj| self.gen_for_node(stream, obj.get("root").ok_or(())?) )
    }

    fn gen_for_node<W: Write>(&self, stream: &mut W, obj: &Obj) -> Result<(), ()> {
        stream.write_all(b"\\node {").map_err(|_| ())?;
        match *obj.borrow() {
            Value::Obj(ref map) => {
                map.get("title").and_then(
                    |inner| inner.borrow()
                                .as_string()
                                .and_then(|s| stream.write_all(s.as_bytes()).ok())
                ).ok_or(())?;
                stream.write_all(b"} ").map_err(|_| ())?;
                map.get("__sons__").ok_or(()).and_then(
                    |inner| inner.borrow().as_list().ok_or(()).and_then(|sons| {
                        for son in sons {
                            stream.write_all(b"child {").map_err(|_| ())?;
                            self.gen_for_node(stream, son)?;
                            stream.write_all(b"} ").map_err(|_| ())?;
                        }
                        Ok(())
                    })
                )?;
            },
            _ => return Err(()),
        }
        Ok(())
    }
}

#[derive(Debug, PartialEq)]
enum Value {
    Integer(i64),
    String(String),
    Obj(HashMap<String, Obj>),
    List(Vec<Obj>),
    Function(Function),
    None,
}

impl Value {
    fn as_string(&self) -> Option<&String> {
        match *self {
            Value::String(ref s) => Some(s),
            _ => None,
        }
    }

    fn as_obj(&self) -> Option<&HashMap<String, Obj>> {
        match *self {
            Value::Obj(ref obj) => Some(obj),
            _ => None,
        }
    }

    fn as_obj_mut(&mut self) -> Option<&mut HashMap<String, Obj>> {
        match *self {
            Value::Obj(ref mut obj) => Some(obj),
            _ => None,
        }
    }

    fn as_list(&self) -> Option<&Vec<Obj>> {
        match *self {
            Value::List(ref list) => Some(list),
            _ => None,
        }
    }

    fn as_list_mut(&mut self) -> Option<&mut Vec<Obj>> {
        match *self {
            Value::List(ref mut list) => Some(list),
            _ => None,
        }
    }
}

type Obj = Rc<RefCell<Value>>;

fn new_obj(value: Value) -> Obj {
    Rc::new(RefCell::new(value))
}

fn none_obj() -> Obj {
    new_obj(Value::None)
}

#[derive(Clone, Debug)]
enum Val {
    Ptr(Obj),
    Acc(Obj, String)
}

impl Val {
    fn new(value: Value) -> Val {
        Val::Ptr(Rc::new(RefCell::new(value)))
    }

    fn take_obj(self) -> Result<Obj, ()> {
        match self {
            Val::Ptr(obj) => Ok(obj),
            Val::Acc(obj, s) => match *obj.borrow() {
                Value::Obj(ref map) => map.get(&s).ok_or(()).map(|x| x.clone()),
                _ => Err(()),
            }
        }
    }

    fn access(&self, s: String) -> Result<Val, ()> {
        match *self {
            Val::Ptr(ref rc) => Ok(Val::Acc(rc.clone(), s)),
            Val::Acc(ref rc, ref s1) => {
                match *rc.borrow() {
                    Value::Obj(ref map) => Ok(Val::Acc(map.get(s1).map(
                       |x| x.clone()
                    ).ok_or(())?, s)),
                    _ => Err(()),
                }
            }
        }
    }
}

#[derive(Debug)]
struct SymbolTable {
    env: Obj,
    upper: Option<Box<SymbolTable>>,
}

impl SymbolTable {
    fn new() -> SymbolTable {
        SymbolTable {
            env: new_obj(Value::Obj(HashMap::new())),
            upper: None,
        }
    }
    fn with_upper(upper: SymbolTable) -> SymbolTable {
        SymbolTable {
            env: new_obj(Value::Obj(HashMap::new())),
            upper: Some(Box::new(upper)),
        }
    }
}

fn is_node(obj: &Obj) -> bool {
    if let Value::Obj(ref mut map) = *obj.borrow_mut() {
        map.get("__class__")
            .and_then(|obj| obj.borrow().as_string().map(|s| s == &"__builtin_node__"))
            .unwrap_or(false)
    } else {
        false
    }
}

pub fn translate_slice<W: Write>(source: &[u8], compiled: &mut W) -> Result<(), ()> {
    let source_code = crate::ast::p_source(source).map_err(|_| ())?.1;
    let mut interpreter = Interpreter::new();
    interpreter.run_stms(&source_code)?;
    interpreter.generate_code(compiled)
}

pub fn translate<R: Read, W: Write>(source: &mut R, compiled: &mut W) -> Result<(), ()> {
    let mut byte_array: Vec<u8> = source.bytes().fold(Ok(Vec::new()),
        |mut acc, x| { acc = acc.and_then(|mut vec| { vec.push(x.map_err(|_| ())?); Ok(vec) }); acc }
    )?;
    byte_array.push(b'#');
    translate_slice(&byte_array, compiled)
}


#[cfg(test)]
mod tests {
    use super::*;

    fn simple_program() -> (Interpreter, Obj) {
        let program = Stms(vec![
            Stm::Single(Expr::Op(
                Ops::Asg,
                P::new(Atom::Ident("a".into())),
                P::new(Expr::Atm(P::new(Atom::Str("Abc".into())))),
            )),
            Stm::Single(Expr::Op(
                Ops::Asg,
                P::new(Atom::Ident("b".into())),
                P::new(Expr::Call(
                    P::new(Atom::Ident("node".into())),
                    Args(vec![
                        Expr::Atm( P::new(Atom::Ident("a".into())) )
                    ]),
                )),
            )),
            Stm::Single(Expr::Op(
                Ops::Asg,
                P::new(Atom::Ident("root".into())),
                P::new(Expr::Call(
                    P::new(Atom::Ident("node".into())),
                    Args(vec![
                        Expr::Atm( P::new(Atom::Ident("a".into())) )
                    ]),
                )),
            )),
            Stm::Single(Expr::Call(
                P::new(Atom::Ident("edge".into())),
                Args(vec![
                    Expr::Atm( P::new(Atom::Ident("root".into())) ),
                    Expr::Atm( P::new(Atom::Ident("b".into())) ),
                ])
            ))
        ]);
        let mut pred_env = HashMap::new();
        pred_env.insert("a".into(), new_obj(Value::String("Abc".into())));
        let b_obj = { // Insert b
            let mut b_map = HashMap::new();
            b_map.insert("__class__".into(), new_obj(Value::String("__builtin_node__".into())));
            b_map.insert("__sons__".into(), new_obj(Value::List(Vec::new())));
            b_map.insert("title".into(), new_obj(Value::String("Abc".into())));
            pred_env.insert("b".into(), new_obj(Value::Obj(b_map.clone())));
            new_obj(Value::Obj(b_map))
        };
        { // Insert c
            let mut b_map = HashMap::new();
            b_map.insert("__class__".into(), new_obj(Value::String("__builtin_node__".into())));
            b_map.insert("__sons__".into(), new_obj(Value::List(vec![b_obj.clone()])));
            b_map.insert("title".into(), new_obj(Value::String("Abc".into())));
            pred_env.insert("root".into(), new_obj(Value::Obj(b_map.clone())));
        }
        let pred_env = new_obj(Value::Obj(pred_env));
        let mut interpreter = Interpreter::new();
        assert_eq!(interpreter.run_stms(&program), Ok(()));
        if let Value::Obj(ref mut map) = *interpreter.table.env.borrow_mut() {
            map.remove("node");
            map.remove("edge");
        }
        (interpreter, pred_env)
    }
    #[test]
    fn interpret_simple_program() {
        let (interpreter, pred_env) = simple_program();
        assert_eq!(interpreter.table.env, pred_env);
    }

    #[test]
    fn generate_simple_program() {
        let (interpreter, _) = simple_program();
        assert_eq!(interpreter.generate_code(&mut std::io::stdout()), Ok(()));
    }

}