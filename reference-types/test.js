// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/reference-types.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let roundtrip = obj.instance.exports.roundtrip;
    let v = roundtrip({foo: 20});
    assert.deepEqual(v, {foo: 20});

    let saveref = obj.instance.exports.saveref;
    let loadref = obj.instance.exports.loadref;

    saveref([10, 20, "foo"]);
    let vout = loadref();
    assert.deepEqual(vout, [10, 20, "foo"]);
})();
