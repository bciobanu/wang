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
        this._proto = grpc.loadPackageDefinition(this._packageDefinition).wang;
        this._grpcClient = new this._proto.Napoca(serverSpec, grpc.credentials.createInsecure());
    }

    /**
     * @param wangCode The request to be handled.
     * @param successCallback A function to be called with the tikz code as argument, if the request was successful.
     * @param errorCallback A function to be called with an array of errors as argument, if the request failed.
     * Errors are in the format described in the napoca.proto file (they have a code and a description).
     * An example of an error is the following:
     *  {
     *      code: {
     *          name: 'NETWORK_ERROR',
     *          number: 1,
     *          options: null
     *      },
     *      description: 'Error: 14 UNAVAILABLE: Connect Failed'
     *  }
     *  The format is the same for all errors (network & compiler).
     */
    requestParse(wangCode, successCallback, errorCallback) {
        this._grpcClient.parse({
            wang_code: wangCode
        }, (err, wangResponse) => {
            if (err != null) {
                errorCallback([{
                    code: this._proto.Error.type.enumType[0].value[1],
                    description: err.toString()
                }]);
            } else if (wangResponse.errors.length > 0) {
                errorCallback(wangResponse.errors);
            } else {
                successCallback(wangResponse.tikz);
            }
        });
    }
};
