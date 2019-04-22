extern crate protobuf;
extern crate grpc;
extern crate futures;
extern crate futures_cpupool;
extern crate tls_api;
extern crate tls_api_stub;
extern crate tls_api_native_tls;

pub mod napoca;
pub mod napoca_grpc;

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
        println!("Wang request with code '{}'", req.get_wang_code());
        r.set_tikz(req.take_wang_code());
        return SingleResponse::completed(r);
    }
}

fn main() {
    let port = 50001;

    let mut server: ServerBuilder<TlsAcceptor> = grpc::ServerBuilder::new();
    server.http.set_port(port);
    server.http.set_cpu_pool_threads(4);
    server.add_service(NapocaServer::new_service_def(NapocaImpl));

    let _server = server.build().expect("server");

    println!("Napoca server started on port {}", port);

    loop {
        thread::park();
    }
}
