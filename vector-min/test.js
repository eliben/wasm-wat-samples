// JS loader and tester for vmin & vargmin.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    const bytes = fs.readFileSync(__dirname + '/vmin.wasm');

    const memory = new WebAssembly.Memory({ initial: 80 });
    const mem_i32 = new Int32Array(memory.buffer);

    let importObject = {
        env: {
            log_i32: function (n) {
                console.log(`log i32: ${n}`);
            },

            log_4xi32: function(n0, n1, n2, n3) {
                console.log(`log 4xi32: ${n0} ${n1} ${n2} ${n3}`);
            },

            buffer: memory
        }
    };

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    let vmin = obj.instance.exports.vmin;
    let vargmin = obj.instance.exports.vargmin;

    // We pass a byte buffer to WASM; in JS, it's convenient to have an
    // Int32Array view on it.
    //
    // memOffset is the offset in mem_i32 where our data starts.
    const memOffset = 128;

    // Initialize data starting at memOffset.
    let initArr = [15, 19, 27, 12, 19, 20, 11, 9, 3, 18, 9, 19, 1, 2, 3, 4, 9, 3, -2, 8];
    mem_i32.set(initArr, memOffset);

    for (let i = memOffset; i < memOffset + 32; i++) {
        console.log(`[${i}  ${i*4}]  ${mem_i32[i]}`);
    }

    // All of 'memory' is shared to WASM. Our data starts at memOffset in the
    // i32 view, so we pass memOffset * 4 as the pointer to the data.
    let minval = vmin(memOffset * 4, initArr.length);
    console.log('minval:', minval);

    let minidx = vargmin(memOffset * 4, initArr.length);
    console.log('minidx:', minidx);
})();
