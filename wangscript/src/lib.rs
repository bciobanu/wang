#![allow(dead_code)]

#[macro_use] extern crate nom;

mod ast;
mod lex;
mod interpret;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
