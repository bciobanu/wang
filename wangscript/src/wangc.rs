extern crate clap;

use std::fs::File;
use std::io::Read;

use clap::{App, Arg};

fn main() {
    let matches = App::new("The Wangscript compiler")
        .version("0.5")
        .arg(Arg::with_name("source")
            .takes_value(true)
            .required(true)
        )
        .arg(Arg::with_name("output")
            .short("o")
            .takes_value(true)
        )
        .get_matches();
    let source_path = matches.value_of("source").expect("expected source path");
    let out_path = matches.value_of("output").unwrap_or("a.out");
    let input = File::open(source_path).expect("file missing");
}