// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/stack.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let result = obj.instance.exports.stack_func_call();
    console.log(`result is = ${result}`);
    assert.equal(result, 91-23);
})();


