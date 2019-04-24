use crate::lex;

/// I'm going to write the grammar here
/// 
/// expr -> atom |
///         atom + expr |
///         atom * expr |
///         atom - expr |
///         atom = expr |
///         atom[expr] |
///         atom(args)
/// atom -> ( expr ) | ident | const
/// args -> eps | expr | expr, args
/// block -> { stms }
/// stms -> stm stms | eps
/// stm -> expr ;
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
    Asg,
    Acc,
}

#[derive(Debug, PartialEq)]
pub(crate) enum Atom {
    Integer(i64),
    Str(String),
    Ident(String),
    Exp(P<Expr>),
}

#[derive(Debug, PartialEq)]
pub(crate) enum Expr {
    Op(Ops, P<Atom>, P<Expr>),
    Atm(P<Atom>),
    Call(P<Atom>, Args),
}

#[derive(Debug, PartialEq)]
pub(crate) enum Stm {
    Single(Expr),
    Block(Stms),
}

#[derive(Debug, PartialEq)]
pub(crate) struct Stms(pub(crate) Vec<Stm>);

#[derive(Debug, PartialEq)]
pub(crate) struct Args(pub(crate) Vec<Expr>);

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
        lex::OpType::Asg => Ops::Asg,
    }
}

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
        ) // atom -> ( expr )
        
        // map!(char!('a'),
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

named!(p_source<&[u8], Stms>, terminated!(p_stms, preceded!(lex::p_spaces, char!('#'))));

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
                    P::new(Atom::Ident("a".into())),
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
                                P::new(Atom::Exp(
                                    P::new(Expr::Op(
                                        Ops::Acc,
                                        P::new(Atom::Ident("a".into())),
                                        P::new(Expr::Atm(P::new(Atom::Str("ceva wtv".into()))))
                                    ))
                                )),
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
        var = 1323 * b + anc[100];
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
                            P::new(Atom::Ident("var".into())),
                            P::new(Expr::Op(
                                Ops::Mul,
                                P::new(Atom::Integer(1323)),
                                P::new(Expr::Op(
                                    Ops::Add,
                                    P::new(Atom::Ident("b".into())),
                                    P::new(Expr::Op(
                                        Ops::Acc,
                                        P::new(Atom::Ident("anc".into())),
                                        P::new(Expr::Atm(P::new(Atom::Integer(100))))
                                    ))
                                ))
                            ))
                        )
                    ),
                    Stm::Block(Stms(vec![
                        Stm::Single(Expr::Op(
                            Ops::Asg,
                            P::new(Atom::Ident("b".into())),
                            P::new(Expr::Atm(P::new(Atom::Integer(3))))
                        )),
                        Stm::Single(Expr::Op(
                            Ops::Asg,
                            P::new(Atom::Ident("c".into())),
                            P::new(Expr::Atm(P::new(Atom::Integer(2))))
                        )),
                    ]))
                ])
            ))
        );
    }
}