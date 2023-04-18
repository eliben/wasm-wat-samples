// Sample of indirect calls in WASM.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const fs = require('fs');
const assert = require('node:assert');

// This object is imported into wasm.
const importObject = {
    env: {
        jstimes3: (n) => 3 * n,
    }
};

(async () => {
    const wasmfile = fs.readFileSync(__dirname + '/table.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(wasmfile), importObject);

    // Get two exported functions from wasm.
    let times2 = obj.instance.exports.times2;
    let times3 = obj.instance.exports.times3;

    console.log('times2(12) =>', times2(12));
    console.log('times3(12) =>', times3(12));

    assert.equal(times2(42), 84);
    assert.equal(times3(53), 159);
})();
