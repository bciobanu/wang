const path = require("path");
const grpc = require('grpc');
const protoLoader = require('@grpc/proto-loader');

exports.NapocaClient = class NapocaClient {
    /**
     * @param serverSpec "IP:port" specification of an HTTP Napoca Server. Example: 'localhost:50051'
     */
    constructor(serverSpec) {
        const protoPath = path.join(__dirname, "..", "proto", "napoca.proto");
        this._packageDefinition = protoLoader.loadSync(protoPath, {
            keepCase: true,
            longs: String,
            enums: String,
            defaults: true,
            oneofs: true
        });
        this._protoDescriptor = grpc.loadPackageDefinition(this._packageDefinition);
        this._grpcClient = new this._protoDescriptor.wang.Napoca(serverSpec, grpc.credentials.createInsecure());
    }

    requestParse(wangCode, successCallback, errorCallback) {
        this._grpcClient.parse({
            wang_code: wangCode
        }, (err, wangResponse) => {
            if (err != null) {
                errorCallback(err);
            } else {
                successCallback(wangResponse.tikz);
            }
        });
    }
};
