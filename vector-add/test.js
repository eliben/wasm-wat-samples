// Testing of the vector addition function.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    const bytes = fs.readFileSync(__dirname + '/vecadd.wasm');

    const memory = new WebAssembly.Memory({ initial: 80 });
    const mem_f32 = new Float32Array(memory.buffer);

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
    let add_scalar = obj.instance.exports.add_scalar_inst;
    let add_vector = obj.instance.exports.add_vec_inst;

    // These are offsets in the m_f32 view.
    const startOffset = 128;
    const count = 1024;
    const destOffset1 = 5000;
    const destOffset2 = 5100;

    // Initialize data in memory.
    for (let i = 0; i < count; i++) {
        let mem_f32_offset = startOffset + i * 4;

        // Populate x,y,z,w
        mem_f32[mem_f32_offset] = i * 10 + 5;
        mem_f32[mem_f32_offset + 1] = i * 11 + 6;
        mem_f32[mem_f32_offset + 2] = i * 12 + 7;
        mem_f32[mem_f32_offset + 3] = i * 13 + 8;
    }

    // Call WASM, passing in parameters scaled to its linear memory.
    add_scalar(startOffset * 4, count, destOffset1 * 4);
    add_vector(startOffset * 4, count, destOffset2 * 4);

    // Read results.
    let destX = mem_f32[destOffset1];
    let destY = mem_f32[destOffset1 + 1];
    let destZ = mem_f32[destOffset1 + 2];
    let destW = mem_f32[destOffset1 + 3];
    console.log(`result: x=${destX}, y=${destY} z=${destZ} w=${destW}`);

    let destXv = mem_f32[destOffset2];
    let destYv = mem_f32[destOffset2 + 1];
    let destZv = mem_f32[destOffset2 + 2];
    let destWv = mem_f32[destOffset2 + 3];
    console.log(`result vec: x=${destXv}, y=${destYv} z=${destZv} w=${destWv}`);

    // Calculate the same sum on the host and compare.
    let sumX = 0, sumY = 0, sumZ = 0, sumW = 0;
    for (let i = 0; i < count; i++) {
        let mem_f32_offset = startOffset + i * 4;
        sumX += mem_f32[mem_f32_offset];
        sumY += mem_f32[mem_f32_offset + 1];
        sumZ += mem_f32[mem_f32_offset + 2];
        sumW += mem_f32[mem_f32_offset + 3];
    }

    assert.equal(destX, sumX);
    assert.equal(destY, sumY);
    assert.equal(destZ, sumZ);
    assert.equal(destW, sumW);

    assert.equal(destXv, sumX);
    assert.equal(destYv, sumY);
    assert.equal(destZv, sumZ);
    assert.equal(destWv, sumW);
})();
