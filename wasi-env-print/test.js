// Sample of using WASI in WASM, with set up env vars.
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
        env: {
            "key1": "val1",
            "foo": "bar",
            "XK": "12998",
        }
    });

    const wasmfile = fs.readFileSync(__dirname + '/envprint.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(wasmfile), wasi.getImportObject());

    wasi.start(obj.instance);
})();
