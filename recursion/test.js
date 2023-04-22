// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/recursion.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    const a = 1;
    const b = 8;

    let factorial = obj.instance.exports.factorial;
    console.log(`7! = ${factorial(7)}`);

    assert.equal(factorial(0), 1);
    assert.equal(factorial(1), 1);
    assert.equal(factorial(2), 2);
    assert.equal(factorial(3), 6);
    assert.equal(factorial(4), 24);
    assert.equal(factorial(7), 5040);
    assert.equal(factorial(12), 479001600);

    let is_even = obj.instance.exports.is_even;
    let is_odd = obj.instance.exports.is_odd;

    assert.equal(is_even(0), 1);
    assert.equal(is_even(1), 0);
    assert.equal(is_even(2), 1);
    assert.equal(is_even(3), 0);
    assert.equal(is_even(4), 1);

    assert.equal(is_odd(0), 0);
    assert.equal(is_odd(1), 1);
    assert.equal(is_odd(2), 0);
    assert.equal(is_odd(3), 1);
    assert.equal(is_odd(4), 0);
})();


