// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/add-not-folded.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    const a = 1;
    const b = 8;
    let result = obj.instance.exports.add(a, b);
    console.log(`${a} + ${b} = ${result}`);

    assert.equal(result, a + b);
})();
