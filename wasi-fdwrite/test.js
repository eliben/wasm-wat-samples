const fs = require("fs");
const { WASI } = require("wasi");

(async () => {
    const wasi = new WASI();
    const importObject = {
        wasi_snapshot_preview1: wasi.wasiImport
    };

    const wasmfile = fs.readFileSync(__dirname + '/write.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(wasmfile), importObject);

    wasi.start(obj.instance);
})();
