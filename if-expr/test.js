// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/ifexpr.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let ifexprfunc = obj.instance.exports.ifexpr;

    console.log(ifexprfunc(10, 33));
    console.log(ifexprfunc(10, -33));

    assert.equal(ifexprfunc(100, 0), 101);
    assert.equal(ifexprfunc(100, 1), 101);
    assert.equal(ifexprfunc(100, 10), 101);
    assert.equal(ifexprfunc(100, -1), 99);
    assert.equal(ifexprfunc(100, -2), 99);
    assert.equal(ifexprfunc(100, -20), 99);
})();


