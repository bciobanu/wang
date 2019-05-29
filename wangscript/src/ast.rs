use crate::lex;

use std::dbg;

/// I'm going to write the grammar here
/// 
/// atom -> ( expr ) | ident | const | list | dict | None
/// args -> eps | expr | expr, args
/// block -> { stms }
/// stms -> stm stms | eps
/// stm -> expr | while (expr) stm
/// 
/// expr -> expr1 | expr1 OP1 expr_f, OP1 = {=}
/// expr_f -> expr1 | expr1 OP1 expr_f
/// expr1 -> expr2 | expr2 OP2 expr1_f, OP2 = {<, >, <=, >=, ==, !=}
/// expr1_f -> expr2 | expr2 OP2 expr1_f
/// expr2 -> expr3 | expr3 OP3 expr2_f, OP3 = {+, -}
/// expr2_f -> expr3 | expr3 OP3 expr2_f
/// expr3 -> expr4 | expr4 OP4 expr3_f, OP3 = {*, /, %}
/// expr3_f => expr4 | expr4 OP4 expr3_f
/// expr4 -> atom acc_list
/// acc_list -> [ expr ] acc_list | ( args ) acc_list | . ident ( args ) | eps
/// 

#[derive(Debug, PartialEq)]
pub(crate) struct P<T> {
    pub(crate) p: Box<T>,
}

impl<T> P<T> {
    pub(crate) fn new(a: T) -> P<T> {
        P { p: Box::new(a) }
    }
}

#[derive(Debug, PartialEq, Clone, Copy)]
pub(crate) enum Ops {
    Add,
    Sub,
    Mul,
    Div,
    Mod,
    Lt,
    Gt,
    Le,
    Ge,
    Eq,
    Ne,
    Asg,
    Acc,
}

impl Ops {
    fn assoc(&self) -> Assoc {
        match *self {
            Ops::Asg => Assoc::Right,
            _ => Assoc::Left,
        }
    }
    
    fn precedence(&self) -> usize {
        match *self {
            Ops::Asg => 0,
            Ops::Lt | Ops::Gt | Ops::Le | Ops::Ge |
                Ops::Eq | Ops::Ne => 1,
            Ops::Add | Ops::Sub => 2,
            Ops::Mul | Ops::Div | Ops::Mod => 3,
            _ => usize::max_value(),
        }
    }
}

#[derive(Debug, PartialEq, Clone, Copy)]
pub(crate) enum Assoc {
    Left, Right
}

#[derive(Debug, PartialEq)]
pub(crate) enum Atom {
    Integer(i64),
    Str(String),
    Ident(String),
    Exp(P<Expr>),
    ListConstruct(Args),
    DictConstruct(DictArgs),
    None,
}

#[derive(Debug, PartialEq)]
pub(crate) enum Expr {
    Op(Ops, P<Expr>, P<Expr>),
    Atm(P<Atom>),
    Call(P<Atom>, Args),
}

#[derive(Debug, PartialEq)]
pub(crate) enum Stm {
    Single(Expr),
    While(Expr, P<Stm>),
    If(Expr, P<Stm>),
    Block(Stms),
}

#[derive(Debug, PartialEq)]
pub(crate) struct Stms(pub(crate) Vec<Stm>);

#[derive(Debug, PartialEq)]
pub(crate) struct Args(pub(crate) Vec<Expr>);

#[derive(Debug, PartialEq)]
pub(crate) struct DictArgs(pub(crate) Vec<(Expr, Expr)>);

#[derive(Debug, PartialEq)]
pub(crate) struct Function {
    pub(crate) name: String,
    pub(crate) args: Vec<String>,
    pub(crate) instr: Stms,
}

// macro_rules! of_class {
//     ($obj:expr, $tt:pat) => {
//         {
//             match $obj {
//                 $tt(..) => true,
//                 _ => false,
//             }
//         }
//     };
// }

macro_rules! dec_then_type {
    ($t1:pat, $($tt:tt)*) => {
        |x| match x { 
            $($tt)*(sep) => match sep {
                $t1 => Some(0),
                _ => None,
            },
            _ => None,
        }
    };
}

fn to_ast_op(op: lex::OpType) -> Ops {
    match op {
        lex::OpType::Add => Ops::Add,
        lex::OpType::Mul => Ops::Mul,
        lex::OpType::Sub => Ops::Sub,
        lex::OpType::Div => Ops::Div,
        lex::OpType::Mod => Ops::Mod,
        lex::OpType::Le => Ops::Le,
        lex::OpType::Ge => Ops::Ge,
        lex::OpType::Lt => Ops::Lt,
        lex::OpType::Gt => Ops::Gt,
        lex::OpType::Eq => Ops::Eq,
        lex::OpType::Ne => Ops::Ne,
        lex::OpType::Asg => Ops::Asg,
    }
}

/*
named!(p_expr<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_atom >>
            op: map!(lex::p_op, |x| match x { lex::Token::Op(op) => to_ast_op(op), _ => panic!(), }) >>
            right: p_expr >>
            ( Expr::Op(op, P::new(left), P::new(right)) )
        ) |
        do_parse!(
            left: p_atom >>
            _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::SqBr)) >>
            right: p_expr >>
            _close: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::SqBr)) >>
            ( Expr::Op(Ops::Acc, P::new(left), P::new(right)) )
        ) |
        do_parse!(
            left: p_atom >>
            _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::Paran)) >>
            right: p_args >>
            _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::Paran)) >>
            ( Expr::Call(P::new(left), right) )
        ) |
        map!(p_atom, |atom| Expr::Atm(P::new(atom))) // 
    )
);*/

fn change_to_left_assoc(mut e: Expr) -> Expr {
    if let &Expr::Op(op, _, _) = &e {
        if op.assoc() == Assoc::Right {
            return e;
        }
    } else {
        return e;
    }
    loop {
        e = match e {
            Expr::Op(op, left, right) => {
                if let &Expr::Op(r_op, _, _) = &right.p as &Expr {
                    if r_op.precedence() != op.precedence() {
                        return Expr::Op(op, left, right);
                    } else {
                        match *right.p {
                            Expr::Op(r_op, r_left, r_right) => {
                                Expr::Op(r_op, P::new(
                                    Expr::Op(op, left, r_left)
                                ), r_right)
                            },
                            _ => panic!("[ast] this case should have been handled above")
                        }
                    }
                } else {
                    return Expr::Op(op, left, right);
                }
            },
            _ => panic!("[ast] the first if should solve this case"),
        }
    }
}

named!(p_expr<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr1 >> 
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Asg => Some(to_ast_op(op)),
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr_f >>
            ( change_to_left_assoc(Expr::Op(op, P::new(left), P::new(right))) )

        ) |
        p_expr1
    )
);

named!(p_expr_f<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr1 >> 
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Asg => Some(to_ast_op(op)),
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr_f >>
            ( Expr::Op(op, P::new(left), P::new(right)) )
        ) |
        p_expr1
    )
);

named!(p_expr1<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr2 >>
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Lt | lex::OpType::Gt | lex::OpType::Le | lex::OpType::Ge |
                        lex::OpType::Eq | lex::OpType::Ne => {
                            Some(to_ast_op(op))
                        },
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr1_f >>
            ( change_to_left_assoc(Expr::Op(op, P::new(left), P::new(right))) )
        ) |
        p_expr2
    )
);

named!(p_expr1_f<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr2 >>
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Lt | lex::OpType::Gt | lex::OpType::Le | lex::OpType::Ge |
                        lex::OpType::Eq | lex::OpType::Ne => {
                            Some(to_ast_op(op))
                        },
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr1_f >>
            ( Expr::Op(op, P::new(left), P::new(right)) )
        ) |
        p_expr2
    )
);

named!(p_expr2<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr3 >>
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Add | lex::OpType::Sub => Some(to_ast_op(op)),
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr2_f >>
            ( change_to_left_assoc(Expr::Op(op, P::new(left), P::new(right))) )
        ) |
        p_expr3
    )
);

named!(p_expr2_f<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr3 >>
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Add | lex::OpType::Sub => Some(to_ast_op(op)),
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr2_f >>
            ( Expr::Op(op, P::new(left), P::new(right)) )
        ) |
        p_expr3
    )
);

named!(p_expr3<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr4 >> 
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Mul | lex::OpType::Div |
                        lex::OpType::Mod => Some(to_ast_op(op)),
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr3_f >> 
            ( change_to_left_assoc(Expr::Op(op, P::new(left), P::new(right))) )
        ) |
        p_expr4
    )
);

named!(p_expr3_f<&[u8], Expr>,
    alt!(
        do_parse!(
            left: p_expr4 >> 
            op: map_opt!(lex::p_op, |x| match x {
                lex::Token::Op(op) => {
                    match op {
                        lex::OpType::Mul | lex::OpType::Div |
                        lex::OpType::Mod => Some(to_ast_op(op)),
                        _ => None,
                    }
                },
                _ => panic!(),
            }) >>
            right: p_expr3_f >> 
            ( Expr::Op(op, P::new(left), P::new(right)) )
        ) |
        p_expr4
    )
);

enum AccListParam {
    Acc(Expr),
    Call(Args),
    MethodCall(String, Args),
}

named!(p_acc_list<&[u8], Vec<AccListParam> >,
    many0!(
        alt!(
            do_parse!(
                _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::SqBr)) >>
                expr: p_expr >>
                _close: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::SqBr)) >>
                ( AccListParam::Acc(expr) )
            ) | // access: some [ ] 
            do_parse!(
                _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::Paran)) >>
                args: p_args >>
                _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::Paran)) >>
                ( AccListParam::Call(args) )
            ) | // call: some ( )
            do_parse!(
                _dot: map_opt!(lex::p_op, dec_then_type!(lex::SepType::Dot, lex::Token::Sep)) >>
                method_name: map_opt!(lex::p_ident, |x| match x {
                    lex::Token::Ident(s) => Some(s),
                    _ => None,
                }) >>
                _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::Paran)) >>
                args: p_args >>
                _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::Paran)) >>
                ( AccListParam::MethodCall(method_name, args) )
            ) // method call: some . name ( ) 
        )
    )
);

fn build_expr4(atom: Atom, acc_list: Vec<AccListParam>) -> Expr {
    let mut ret = Expr::Atm(P::new(atom));
    for param in acc_list {
        match param {
            AccListParam::Acc(expr) => {
                ret = Expr::Op(Ops::Acc, P::new(ret), P::new(expr));
            },
            AccListParam::Call(args) => { ret = Expr::Call(P::new(Atom::Exp(P::new(ret))), args); },
            AccListParam::MethodCall(name, mut args) => {
                args.0.insert(0, ret);
                ret = Expr::Call(P::new(Atom::Ident(name)), args);
            },
        }
    }
    ret
}

named!(p_expr4<&[u8], Expr>,
    do_parse!(
        atom: p_atom >>
        acc_list: p_acc_list >> 
        ( build_expr4(atom, acc_list) )
    )
);

named!(p_atom<&[u8], Atom>,
    alt!(
        map!(lex::p_ident, |x| match x { lex::Token::Ident(s) => Atom::Ident(s), _ => panic!() }) | // atom -> ident
        map_opt!(lex::p_number,
            |x| match x {
                lex::Token::Number(s) => Some(Atom::Integer(
                        match s.parse::<i64>() {
                            Ok(res) => res,
                            Err(_) => return None,
                        }
                    )),
                _ => panic!(),
            }
        ) | // atom -> number
        map!(lex::p_str, |x| match x { lex::Token::Str(s) => Atom::Str(s), _ => panic!() }) | // atom -> str
        delimited!(
            map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::Paran)),
            map!(p_expr, |x| Atom::Exp(P::new(x))),
            map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::Paran))
        ) | // atom -> ( expr )
        do_parse!(
            _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::SqBr)) >>
            args: p_args >>
            _closed: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::SqBr)) >>
            ( Atom::ListConstruct(args) )
        ) | // atom -> list
        map_opt!(lex::p_keyword, |x| match x {
            lex::Token::Keyword(keyword) => match keyword {
                lex::Keyword::None => Some(Atom::None),
                _ => None,
            },
            _ => panic!(),
        }) // atom -> None
    )
);

named!(p_args<&[u8], Args >,
    do_parse!(
        first: p_expr >>
        rest: many0!(preceded!(map_opt!(lex::p_sep, dec_then_type!(lex::SepType::Comma, lex::Token::Sep)), p_expr)) >>
        ({let mut rest = rest; rest.insert(0, first); Args(rest)})
    ) // args -> expr, args | eps
);

named!(p_stms<&[u8], Stms>,
    map!(many0!(p_stm), |stms| Stms(stms)) // stms -> stm stms | eps
);

named!(p_stm<&[u8], Stm>,
    alt!(
        do_parse!(
            _keyword: map_opt!(lex::p_keyword, dec_then_type!(lex::Keyword::If, lex::Token::Keyword)) >>
            _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::Paran)) >>
            expr: p_expr >>
            _close: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::Paran)) >>
            stm: p_stm >>
            ( Stm::If(expr, P::new(stm)) )
        ) | // stm -> if ( expr ) stm
        do_parse!(
            _keyword: map_opt!(lex::p_keyword, dec_then_type!(lex::Keyword::While, lex::Token::Keyword)) >>
            _open: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::Paran)) >>
            expr: p_expr >>
            _close: map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::Paran)) >>
            stm: p_stm >>
            ( Stm::While(expr, P::new(stm)) )
        ) | // stm -> while ( expr ) stm
        p_block | // stm -> block
        terminated!(
            map!(p_expr, |exp| Stm::Single(exp)),
            map_opt!(lex::p_sep, dec_then_type!(lex::SepType::SemiCol, lex::Token::Sep))
        ) // stm -> expr ;
    )
);

named!(p_block<&[u8], Stm>,
    delimited!(
        map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Open, lex::Token::Bracket)),
        map!(p_stms, |stms| Stm::Block(stms)),
        map_opt!(lex::p_braces, dec_then_type!(lex::DelimType::Close, lex::Token::Bracket))
    ) // block -> { stms }
);

named!(pub(crate) p_source<&[u8], Stms>, terminated!(p_stms, preceded!(lex::p_spaces, char!('#'))));

#[cfg(test)]
mod tests {
    #[test]
    fn sample_expr() {
        use super::*;
        assert_eq!(
            p_expr(&b"a = 100#"[..]),
            Ok((
                &b"#"[..],
                Expr::Op(
                    Ops::Asg,
                    P::new(Expr::Atm(P::new(Atom::Ident("a".into())))),
                    P::new(Expr::Atm(
                        P::new(Atom::Integer(100))
                    ))
                )
            ))
        );
    }

    #[test]
    fn sample_program1() {
        use super::*;
        let prog = b"(a[\"ceva wtv\"]) = 100; #";
        assert_eq!(
            p_source(&prog[..]),
            Ok(
                (&b""[..],
                Stms(
                    vec![
                        Stm::Single(
                            Expr::Op(
                                Ops::Asg,
                                P::new(Expr::Atm(P::new(Atom::Exp(
                                    P::new(Expr::Op(
                                        Ops::Acc,
                                        P::new(Expr::Atm(P::new(Atom::Ident("a".into())))),
                                        P::new(Expr::Atm(P::new(Atom::Str("ceva wtv".into()))))
                                    ))
                                )))),
                                P::new(Expr::Atm(P::new(Atom::Integer(100i64))))
                            )
                        )
                    ]
                ))
            )
        );
    }

    #[test]
    fn sample_program2() {
        use super::*;
        let prog = br"
        var = 1323 * b * 3 + anc[100];
        {
            b = 3;
            c = 2;
        }
        #";
        assert_eq!(
            p_source(&prog[..]),
            Ok(( &b""[..],
                Stms(vec![
                    Stm::Single(
                        Expr::Op(
                            Ops::Asg,
                            P::new(Expr::Atm(P::new(Atom::Ident("var".into())))),
                            P::new(Expr::Op(
                                Ops::Add,
                                P::new(Expr::Op(
                                    Ops::Mul,
                                    P::new(Expr::Op(
                                        Ops::Mul,
                                        P::new(Expr::Atm(P::new(Atom::Integer(1323)))),
                                        P::new(Expr::Atm(P::new(Atom::Ident("b".into())))),
                                    )),
                                    P::new(Expr::Atm(P::new(Atom::Integer(3))))
                                )),
                                P::new(Expr::Op(
                                    Ops::Acc,
                                    P::new(Expr::Atm(P::new(Atom::Ident("anc".into())))),
                                    P::new(Expr::Atm(P::new(Atom::Integer(100))))
                                ))
                            ))
                        )
                    ),
                    Stm::Block(Stms(vec![
                        Stm::Single(Expr::Op(
                            Ops::Asg,
                            P::new(Expr::Atm(P::new(Atom::Ident("b".into())))),
                            P::new(Expr::Atm(P::new(Atom::Integer(3))))
                        )),
                        Stm::Single(Expr::Op(
                            Ops::Asg,
                            P::new(Expr::Atm(P::new(Atom::Ident("c".into())))),
                            P::new(Expr::Atm(P::new(Atom::Integer(2))))
                        )),
                    ]))
                ])
            ))
        );
    }
}