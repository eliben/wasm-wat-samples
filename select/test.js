// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/select.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    const a = 1;
    const b = 8;

    let add_or_sub = obj.instance.exports.add_or_sub;
    
    let sum = add_or_sub(a, b, 20);
    console.log(`${a} + ${b} = ${sum}`);

    let diff = add_or_sub(a, b, -5);
    console.log(`${a} - ${b} = ${diff}`);

    assert.equal(add_or_sub(3, 11, 0), 14);
    assert.equal(add_or_sub(3, 11, 1), 14);
    assert.equal(add_or_sub(3, 11, 999), 14);
    assert.equal(add_or_sub(3, 11, -1), -8);
    assert.equal(add_or_sub(3, 11, -20), -8);
})();


