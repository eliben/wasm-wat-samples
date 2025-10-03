// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/memory-multiple.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let memX = obj.instance.exports.memX;
    let memY = obj.instance.exports.memY;

    // Fill in memX with data, then ask the exported docopy() to copy it to
    // memY, then use the exported sum_some_items to calculate a sum from memY.
    let dview = new DataView(memX.buffer);
    for (let i = 0; i < 16; i += 4) {
        dview.setInt8(i, i*10+20);
    }

    let docopy = obj.instance.exports.docopy;
    docopy(64);
    memdump(memY, 0, 32);
    
    let sum_some_items = obj.instance.exports.sum_some_items;
    let result = sum_some_items();

    // Expect sum at mem[4]+mem[8]
    assert.equal(result, 60+100);
})();

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
