// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/gc-cast-check-and-i31.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let arrRef = obj.instance.exports.make();
    let sum = obj.instance.exports.sum_i31s(arrRef);
    console.log(`sum = ${sum}`);

    assert.equal(sum, 127);
})();
