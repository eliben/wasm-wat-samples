// Sample of using WASI in WASM and loading it from Node.js
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const fs = require("fs");

// This uses experimental APIs described here: https://nodejs.org/api/wasi.html
// and requires Node 20+
const { WASI } = require("wasi");

(async () => {
    const wasi = new WASI({
        version: "preview1",
    });

    const wasmfile = fs.readFileSync(__dirname + '/write.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(wasmfile), wasi.getImportObject());

    wasi.start(obj.instance);
})();
