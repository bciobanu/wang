#![allow(dead_code)]

#[macro_use] extern crate nom;

pub mod ast;
pub mod lex;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
