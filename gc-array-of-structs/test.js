// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/gc-array-of-structs.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let make = obj.instance.exports.make;
    let set = obj.instance.exports.set;
    let is_valid = obj.instance.exports.is_valid;
    let get_xy = obj.instance.exports.get_xy;

    let arr = make(5);
    set(arr, 0, 1.5, 6.25);
    set(arr, 4, -2.125, 13);

    let totalx = 0, totaly = 0;
    for (let i = 0; i < 5; i++) {
        if (Boolean(is_valid(arr, i))) {
            let [x, y] = get_xy(arr, i);
            totalx += x;
            totaly += y;
        }
    }

    assert.equal(totalx, -0.625);
    assert.equal(totaly, 19.25)
})();
