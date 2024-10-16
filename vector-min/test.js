// JS loader and tester for the sample.
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

            buffer: memory
        }
    };

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    let vmin = obj.instance.exports.vmin;
    // let i32min = obj.instance.exports.i32min;

    // Offset of parameter in the m_u32 view.
    const memOffset = 128;

    mem_i32.set([15, 19, 27, 12, 19, 20, 11, 9], memOffset);
    // mem_i32[memOffset] = 179;
    // mem_i32[memOffset + 1] = 0xC0DECAFE;
    // mem_u32[memOffset + 2] = 0xABBABABA;
    // mem_u32[memOffset + 3] = 0xF00DD00D;

    for (let i = memOffset; i < memOffset + 16; i++) {
        console.log(`[${i}  ${i*4}]  ${mem_i32[i]}`);
    }

    let m = vmin(memOffset * 4, 8);
    console.log('m:', m);

})();
