use nom::{alpha, digit, digit0};

#[derive(Debug, PartialEq)]
pub(crate) enum DelimType {
    Open,
    Close,
}

#[derive(Debug, PartialEq, Clone, Copy)]
pub(crate) enum OpType {
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
}

#[derive(Debug, PartialEq)]
pub(crate) enum SepType {
    Comma,
    SemiCol,
    Dot,
}

#[derive(Debug, PartialEq)]
pub(crate) enum Keyword {
    While,
    If,
    None,
}

#[derive(Debug, PartialEq)]
pub(crate) enum Token {
    Keyword(Keyword),
    Ident(String),
    Str(String),
    Number(String),
    Bracket(DelimType),
    Paran(DelimType),
    SqBr(DelimType),
    Op(OpType),
    Sep(SepType)
}

fn to_string(a: &[u8]) -> String {
    String::from_utf8(a.to_vec()).expect("conversion failed")
}

named!(pub(crate) p_spaces<&[u8], Vec<char>>, many0!(one_of!(" \n\r\t")));

named!(pub(crate) p_ident<&[u8], Token>,
    do_parse!(
        _sp: p_spaces            >>
        first: alpha             >> 
        rest: digit0       >>
        ( Token::Ident(to_string(first) + &to_string(rest)) )
    )
);

named!(pub(crate) p_str<&[u8], Token>,
    do_parse!(
        _sp: p_spaces >>
        char!('"')                  >>
        inner: take_until!("\"")    >>
        char!('"')                  >> 
        ( Token::Str(to_string(inner)) )
    )
);

named!(pub(crate) p_number<&[u8], Token>,
    preceded!(p_spaces,
        map!(digit::<&[u8]>, |x| Token::Number(to_string(x)))
    )
);

fn char_to_delim(c: char) -> Token {
    match c {
        '{' => Token::Bracket(DelimType::Open),
        '}' => Token::Bracket(DelimType::Close),
        '(' => Token::Paran(DelimType::Open),
        ')' => Token::Paran(DelimType::Close),
        '[' => Token::SqBr(DelimType::Open),
        ']' => Token::SqBr(DelimType::Close),
        _ => panic!("wrong delimiter"),
    }
}
named!(pub(crate) p_braces<&[u8], Token>,
    preceded!(p_spaces,
        map!(one_of!("{}[]()"), char_to_delim)
    )
);

fn slice_to_op(s: &[u8]) -> OpType {
    match s {
        b"+" => OpType::Add,
        b"-" => OpType::Sub,
        b"*" => OpType::Mul,
        b"/" => OpType::Div,
        b"%" => OpType::Mod,
        b"<=" => OpType::Le,
        b">=" => OpType::Ge,
        b"<" => OpType::Lt,
        b">" => OpType::Gt,
        b"==" => OpType::Eq,
        b"!=" => OpType::Ne,
        b"=" => OpType::Asg,
        _ => panic!("wrong operator"),
    }
}

named!(pub(crate) p_keyword<&[u8], Token>,
    preceded!(p_spaces,
        alt!(
            map!(
                tag!("while"), |_| Token::Keyword(Keyword::While)
            ) |
            map!(
                tag!("if"), |_| Token::Keyword(Keyword::If)
            ) |
            map!(
                tag!("None"), |_| Token::Keyword(Keyword::None)
            )
        )
    )
);

named!(pub(crate) p_op<&[u8], Token>,
    preceded!(p_spaces, map!(
            alt!(
                tag!("+") |
                tag!("-") |
                tag!("*") |
                tag!("/") |
                tag!("%") |
                tag!("<=") |
                tag!(">=") |
                tag!("<") |
                tag!(">") |
                tag!("==") |
                tag!("!=") |
                tag!(".") |
                tag!("=")
            ),
            |x| Token::Op(slice_to_op(x))
        )
    )
);

fn char_to_sep(c: char) -> SepType {
    match c {
        ',' => SepType::Comma,
        ';' => SepType::SemiCol,
        '.' => SepType::Dot,
        _ => panic!("wrong sep type")
    }
}

named!(pub(crate) p_sep<&[u8], Token>,
    preceded!(p_spaces,
        map!(one_of!(",;"), |x| Token::Sep(char_to_sep(x)))
    )
);

named!(pub(crate) p_token<&[u8], Token>,
    alt!(
        p_keyword |
        p_ident |
        p_number |
        p_str |
        p_braces |
        p_op |
        p_sep
    )
);

named!(pub(crate) p_tokens<&[u8], Vec<Token> >,
    terminated!(many0!(p_token), preceded!(p_spaces, char!('#')))
);

#[cfg(test)]
mod tests {
    #[test]
    fn test_identifier() {
        use super::*;
        assert_eq!(
            p_ident(&b"abcd123  "[..]),
            Ok( (&b"  "[..], Token::Ident("abcd123".into())) )
        );
    }

    #[test]
    fn test_tokens() {
        use super::*;
        let text = br##"ab = 1;
            c = "1 2 3 4", 
            #"##;
        let expected = vec![
            Token::Ident("ab".into()),
            Token::Op(OpType::Asg),
            Token::Number("1".to_string()),
            Token::Sep(SepType::SemiCol),
            Token::Ident("c".into()),
            Token::Op(OpType::Asg),
            Token::Str("1 2 3 4".to_string()),
            Token::Sep(SepType::Comma),
        ];
        assert_eq!(p_tokens(&text[..]), Ok( (&b""[..], expected) ));
    }
}