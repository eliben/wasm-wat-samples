// Sample of using WASI in WASM and loading it from Node.js
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require("fs");

// This uses experimental APIs described here: https://nodejs.org/api/wasi.html
// and requires Node 20+
const { WASI } = require("wasi");

(async () => {
    // Create an output file to redirect the WASI output to.
    const outFilename = __dirname + '/test.out'
    let outfd = fs.openSync(outFilename, 'w');

    const wasi = new WASI({
        version: "preview1",
        stdout: outfd,
    });

    const wasmfile = fs.readFileSync(__dirname + '/write.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(wasmfile), wasi.getImportObject());

    wasi.start(obj.instance);

    // Now read the output, emit it and test.
    fs.closeSync(outfd);
    let wasiout = new TextDecoder('utf8').decode(fs.readFileSync(outFilename));
    console.log("WASM run successfully with stdout:");
    console.log(wasiout);

    assert.equal(wasiout, "hello from wat!\n");
})();
