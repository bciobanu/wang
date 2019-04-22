const napoca_client = require("./index");

const port = process.argv[2];
console.log("[Napoca Client] Trying to send a request to Napoca, on localhost:" + port);

const client = new napoca_client.NapocaClient("localhost:" + port);

client.requestParse("Hello, World!", (tikz) => {
    console.log("[Napoca Client] Received response: '" + tikz + "'");
    if (tikz === "Hello, World!") {
        console.log("[Napoca Client] Success!");
        process.exit(0);
    } else {
        console.log("[Napoca Client] Response is unexpected!");
        process.exit(1);
    }
}, (err) => {
    console.error("[Napoca Client] Failed with error: ", err);
    process.exit(1);
});
