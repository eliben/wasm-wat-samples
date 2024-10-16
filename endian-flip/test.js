// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    const bytes = fs.readFileSync(__dirname + '/endianflip.wasm');

    const memory = new WebAssembly.Memory({ initial: 80 });
    const mem_u32 = new Uint32Array(memory.buffer);

    let importObject = {
        env: {
            log_i32: function (n) {
                console.log(`log i32: ${n}`);
            },

            log_f32: function (n) {
                console.log(`log f32: ${n}`);
            },

            buffer: memory
        }
    };

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    let endianflip = obj.instance.exports.endianflip;

    // Offset of parameter in the m_u32 view.
    const memOffset = 128;

    // Fill up the destination buffer with four pre-defined 4-byte words. On
    // typical machines these will be written in little-endian order.
    mem_u32[memOffset] = 0xDEADBEEF;
    mem_u32[memOffset + 1] = 0xC0DECAFE;
    mem_u32[memOffset + 2] = 0xABBABABA;
    mem_u32[memOffset + 3] = 0xF00DD00D;

    // Create a u8 view and a copy. mem_u8 is going to be modified by the call
    // to endianflip.
    const mem_u8 = new Uint8Array(memory.buffer);
    const mem_u8_copy = new Uint8Array(mem_u8);

    // Invoke the WASM function to flip from LE to BE.
    endianflip(memOffset * 4);

    for (let i = memOffset * 4; i < memOffset * 4 + 16; i++) {
        console.log(`[${i}]  `,
                    'in:', mem_u8_copy[i].toString(16).padStart(2, '0'),
                    '    out:', mem_u8[i].toString(16).padStart(2, '0'));
    }

    for (let i = memOffset * 4; i < memOffset * 4 + 16; i += 4) {
        assert.equal(mem_u8[i], mem_u8_copy[i + 3]);
        assert.equal(mem_u8[i + 1], mem_u8_copy[i + 2]);
    }
})();
