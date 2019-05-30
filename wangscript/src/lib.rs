#![allow(dead_code)]

#[macro_use] extern crate nom;

mod ast;
mod lex;
pub mod interpret;

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    fn gcd_program() {
        let program = br"
            a = 4 * 5 * 9;
            b = 2 * 5 * 27;
            while (b != 0) {
                c = a % b;
                a = b;
                b = c;
            }
            write(a);
        #";
        use crate::interpret::get_stdout;
        assert_eq!(
            get_stdout(&program[..]),
            Ok("90".to_string())
        );
        // This is not enough, it whould print 2 * 5 * 9 = 90 at stdout
    }

    #[test]
    fn prime_filter() {
        let program = br###"
            n = 30;
            primes = [0];
            i = 0;
            while (i <= n) {
                primes = primes + [1];
                i = i + 1;
            }
            i = 2;
            while (i <= n) {
                if (primes[i] == 1) {
                    j = i + i;
                    while (j <= n) {
                        primes[j] = 0;
                        j = j + i;
                    }
                }
                i = i + 1;
            }
            primelist = [0];
            i = 2;
            while (i <= n) {
                if (primes[i] == 1) {
                    primelist = primelist + [i];
                }
                i = i + 1;
            }
            write(primelist);
        #"###;
        use crate::interpret::get_stdout;
        // std::dbg!(crate::ast::p_source(&program[..]));
        assert_eq!(
            get_stdout(&program[..]),
            Ok("[0, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29]".to_string())
        );
    }

    #[test]
    fn build_tree() {
        let program = br###"
        n = 7;
        nodes = [node(str(0))];
        i = 1;
        while (i <= n) {
            nodes = nodes + [ node(str(i)) ];
            edge(nodes[i / 2], nodes[i]);
            write(i);
            i = i + 1;
        }
        generate(nodes[0]);
        #"###;
        use crate::interpret::{get_stdout, translate_slice};
        assert_eq!(
            get_stdout(&program[..]).map(|_| ()),
            Ok(())
        );
        let mut v = Vec::<u8>::new();
        translate_slice(&program[..], &mut v).unwrap();
        println!("{}", String::from_utf8(v).unwrap());
    }
}
