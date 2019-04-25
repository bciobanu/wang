extern crate simple_logger;
#[macro_use] extern crate log;

extern crate protobuf;
extern crate grpc;
extern crate futures;
extern crate futures_cpupool;
extern crate tls_api;
extern crate tls_api_stub;
extern crate tls_api_native_tls;
extern crate wangscript;

pub mod napoca;
pub mod napoca_grpc;

use std::env;
use std::thread;

use grpc::ServerBuilder;
use grpc::SingleResponse;
use grpc::RequestOptions;
use tls_api_stub::TlsAcceptor;

use napoca::WangRequest;
use napoca::WangResponse;
use napoca_grpc::Napoca;
use napoca_grpc::NapocaServer;

struct NapocaImpl;

impl Napoca for NapocaImpl {
    fn parse(&self, _: RequestOptions, mut req: WangRequest) -> SingleResponse<WangResponse> {
        let mut r = WangResponse::new();

        let wang_code = req.take_wang_code();

        info!(target: "requests", "Wang request with code of length = '{}'", wang_code.len());

        let mut tikz = Vec::<u8>::new();
        let result = wangscript::interpret::translate(&mut wang_code.as_bytes(), &mut tikz);

        if result.is_err() {
            let mut err = napoca::Error::new();
            err.set_code(napoca::Error_Code::UNKNOWN_INTERPRETER_ERROR);
            err.set_description("Unknown interpreter error.".to_string());
            r.mut_errors().push(err);
        } else {
            r.set_tikz(String::from_utf8(tikz).unwrap());
        }

        return SingleResponse::completed(r);
    }
}

fn main() {
    simple_logger::init_with_level(log::Level::Info).unwrap();

    let args: Vec<String> = env::args().collect();
    let port: u16;
    if args.len() >= 2 {
        port = args[1].parse().unwrap();
    } else {
        port = 50001;
    }

    let mut server: ServerBuilder<TlsAcceptor> = grpc::ServerBuilder::new();
    server.http.set_port(port);
    server.http.set_cpu_pool_threads(4);
    server.add_service(NapocaServer::new_service_def(NapocaImpl));

    let _server = server.build().expect("server");

    info!("Napoca server started on port {}", port);

    loop {
        thread::park();
    }
}
