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

    let sub = obj.instance.exports.stack_func_call();
    console.log(`subresult is = ${sub}`);
    assert.equal(sub, 91-23);

    let greater = obj.instance.exports.greater(21, 15);
    console.log(`greater(21, 16) = ${greater}`);

    assert.equal(obj.instance.exports.greater(21, 15), 1);
    assert.equal(obj.instance.exports.greater(11, 15), 0);
    assert.equal(obj.instance.exports.greater(21, 21), 0);

    assert.equal(obj.instance.exports.two_a_plus_b(2, 4), 8);
    assert.equal(obj.instance.exports.two_a_plus_b(-2, 4), 0);
    assert.equal(obj.instance.exports.two_a_plus_b(13, 3), 29);

    assert.deepEqual(obj.instance.exports.tee_for_two(13, 3), [29, 16]);
    assert.deepEqual(obj.instance.exports.tee_for_two(-9, 30), [12, 21]);
})();
