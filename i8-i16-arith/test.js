// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    let importObject = {
        env: {
            log_i32: n => {
                console.log(`log i32: ${n}`);
            }
        }
    };

    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/i8-i16-arith.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    let main = obj.instance.exports.main;
    main();
})();
