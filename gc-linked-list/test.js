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

    let makelist = obj.instance.exports.makelist;
    let addup = obj.instance.exports.addup;

    // The reference value returned from makelist is opaque to the host: we
    // cannot examine it. But we can pass it back into the WASM.
    let lst10 = makelist(10);
    let s1 = addup(lst10);
    assert.equal(s1, 55);

    let lst100 = makelist(100);
    let s2 = addup(lst100);
    assert.equal(s2, 5050);
})();
