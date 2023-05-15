// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    const bytes = fs.readFileSync(__dirname + '/loops.wasm');

    // Create a memory buffer to share with the WASM module, and an i32 view
    // into this buffer.
    const memory = new WebAssembly.Memory({ initial: 80 });
    const mem_i32 = new Int32Array(memory.buffer);

    let importObject = {
        env: {
            log_i32: n => {
                console.log(`log i32: ${n}`);
            },

            rand_i32: () => {
                return Math.floor(Math.random() * 10000);
            },

            buffer: memory
        }
    };

    const startOffset = 128;
    const count = 50;

    // Initialize data in memory.
    for (let i = 0; i < count; i++) {
        mem_i32[startOffset + i] = i*2 - 1;
    }

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    let add_all = obj.instance.exports.add_all;
    let rand_multiple_of_10 = obj.instance.exports.rand_multiple_of_10;
    let first_power_over_limit = obj.instance.exports.first_power_over_limit;

    let result = add_all(startOffset * 4, count);

    let want_sum = 0;
    for (let i = 0; i < count; i++) {
        want_sum += mem_i32[startOffset + i];
    }

    console.log("testing");
    assert.equal(result, want_sum);

    for (let i = 0; i < 100; i++) {
        // Make sure rand_multiple_of_10 always returns a multiple of 10.
        let r10 = rand_multiple_of_10();
        assert.equal(r10 % 10, 0);
    }

    assert.equal(first_power_over_limit(2, 1000), 1024);
    assert.equal(first_power_over_limit(2, 16), 32);
    assert.equal(first_power_over_limit(2, 0), 1);
    assert.equal(first_power_over_limit(3, 25), 27);
    assert.equal(first_power_over_limit(25, 10000), 15625);
})();
