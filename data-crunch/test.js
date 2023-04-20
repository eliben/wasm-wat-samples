// 
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    const bytes = fs.readFileSync(__dirname + '/vecadd.wasm');

    const memory = new WebAssembly.Memory({initial: 80});
    const mem_f32 = new Float32Array(memory.buffer);

    let importObject = {
        env: {
            log: function (n) {
                console.log(`log: ${n}`);

            },

            buffer: memory
        }
    };

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    let vecadd = obj.instance.exports.do_add;

    // These are the parameters we're going to pass to vecadd; they are offsets
    // in the m_f32 view.
    const startOffset = 128;
    const count = 1024;
    const destOffset = 5000;

    // Initialize data in memory.
    for (let i = 0; i < count; i++) {
        let mem_f32_offset = startOffset + i*3;

        // Populate x,y,z
        mem_f32[mem_f32_offset] = i*10 + 5;
        mem_f32[mem_f32_offset+1] = i*11 + 6;
        mem_f32[mem_f32_offset+2] = i*12 + 7;        
    }

    // Call WASM, passing in parameters scaled to its linear memory.
    vecadd(startOffset * 4, count, destOffset * 4);

    // Read results.
    let destX = mem_f32[destOffset];
    let destY = mem_f32[destOffset + 1];
    let destZ = mem_f32[destOffset + 2];

    console.log(`result: x=${destX}, y=${destY} z=${destZ}`);
})();
