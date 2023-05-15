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
    const bytes = fs.readFileSync(__dirname + '/memory-basics.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    // Get wasm's memory and check its size.
    let mem = obj.instance.exports.memory;
    assert.equal(mem.buffer.byteLength, 64 * 1024);
    memdump(mem, 0, 64);

    // Use wasm's own memory.grow to grow memory by 5 pages.
    let wasm_grow = obj.instance.exports.wasm_grow;
    let sz = wasm_grow(5);
    assert.equal(sz, 1);
    assert.equal(mem.buffer.byteLength, 6 * 64 * 1024);

    // The memory's contents are preserved after growing it.
    memdump(mem, 0, 64);

    // Now further grow memory from the host.
    mem.grow(3);
    assert.equal(mem.buffer.byteLength, 9 * 64 * 1024);
    memdump(mem, 0, 64);

    let wasm_size = obj.instance.exports.wasm_size;
    assert.equal(wasm_size(), 9);

    let wasm_fill = obj.instance.exports.wasm_fill;
    wasm_fill(16, 0x22, 8);
    memdump(mem, 0, 64);
})();
