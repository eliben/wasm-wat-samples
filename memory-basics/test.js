// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/memory-basics.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let mem = obj.instance.exports.memory;
    console.log(`Initial memory size: ${mem.buffer.byteLength}`);

    let view = new Uint8Array(mem.buffer);
    for (let i = 0; i < 64; i++) {
        console.log(`${view[i].toString(16).toUpperCase().padStart(2, '0')} `);
    }

})();


