// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/gc-linked-list.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let globalhead = obj.instance.exports.globalhead;
    let makelist = obj.instance.exports.makelist;
    let addup = obj.instance.exports.addup;
    makelist();
    let s1 = addup();

    assert.equal(s1, 5050);
    console.log(s1);
})();
