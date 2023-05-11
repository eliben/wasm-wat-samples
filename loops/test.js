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
            log_i32: function (n) {
                console.log(`log i32: ${n}`);
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

    let result = add_all(startOffset * 4, count);

    let want_sum = 0;
    for (let i = 0; i < count; i++) {
        want_sum += mem_i32[startOffset + i];
    }

    console.log("testing");
    assert.equal(result, want_sum);
})();


