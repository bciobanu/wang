extern crate protobuf;
extern crate grpc;
extern crate futures;
extern crate futures_cpupool;
extern crate tls_api;
extern crate tls_api_stub;
extern crate tls_api_native_tls;

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

        // TODO(darius98): Use a logging library
        println!("Wang request with code '{}'", wang_code);

        // TODO(darius98): Call AndreiNet's implementation here!
        let tikz = wang_code;

        r.set_tikz(tikz);

        return SingleResponse::completed(r);
    }
}

fn main() {
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

    // TODO(darius98): Use a logging library
    println!("Napoca server started on port {}", port);

    loop {
        thread::park();
    }
}
