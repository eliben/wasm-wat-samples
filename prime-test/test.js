// Load and test the `is_prime` WASM function.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    const n = parseInt(process.argv[2] || "42");
    const bytes = fs.readFileSync(__dirname + '/isprime.wasm');

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));
    let answer = Boolean(obj.instance.exports.is_prime(n));
    console.log(`is_prime(${n})=${answer}`);

    do_test(obj.instance.exports.is_prime);
})();

function do_test(is_prime_func) {
    assert.equal(is_prime_func(0), 0);
    assert.equal(is_prime_func(1), 0);
    assert.equal(is_prime_func(2), 1);
    assert.equal(is_prime_func(3), 1);
    assert.equal(is_prime_func(4), 0);
    assert.equal(is_prime_func(5), 1);
    assert.equal(is_prime_func(6), 0);
    assert.equal(is_prime_func(7), 1);
    assert.equal(is_prime_func(8), 0);
    assert.equal(is_prime_func(9), 0);
    assert.equal(is_prime_func(10), 0);
    assert.equal(is_prime_func(11), 1);
    assert.equal(is_prime_func(12), 0);
    assert.equal(is_prime_func(12), 0);

    assert.equal(is_prime_func(787573), 1);
    assert.equal(is_prime_func(787571), 0);
}
