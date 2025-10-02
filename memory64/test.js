// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

// Dumps a WebAssembly.Memory object's contents starting at `start`, for `len`
// bytes in groups of 16.
function memdump(mem, start, len) {
    let view = new Uint8Array(mem.buffer);
    for (let i = 0; i < len; i++) {
        let index = start + i;
        process.stdout.write(`${view[index].toString(16).toUpperCase().padStart(2, '0')} `);
        if ((index + 1) % 16 === 0) {
            console.log();
        }
    }
    console.log();
}

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/memory64.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    // Get wasm's memory and check its size.
    let mem = obj.instance.exports.memory;
    assert.equal(mem.buffer.byteLength, 128 * 1024);
    memdump(mem, 0, 64);

    // i64 in wasm is represented as BigInt in JS.
    let wasm_size = obj.instance.exports.wasm_size;
    assert.equal(wasm_size(), 2);
    assert.equal(typeof(wasm_size()), 'bigint');

    // Since wasm_fill's params are (i64, i32, i64), we pass
    // BigInt constants.
    let wasm_fill = obj.instance.exports.wasm_fill;
    wasm_fill(16n, 0x22, 8n);
    memdump(mem, 0, 64);

    let view = new Uint8Array(mem.buffer);
    assert.equal(view[0], 0x67);
    assert.equal(view[16], 0x22);
    assert.equal(view[32], 0x01);
})();
