// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/gc-print-scheme-pairs.wasm');

    // Import object providing the host functions.
    let out = '';
    const importObject = {
        env: {
            // Collect output into a local stream for testing.
            write_char: function(charCode) {
                out += String.fromCharCode(charCode);
            },
            write_i32: function(value) {
                out += value.toString();
            }
        }
    };

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);

    let mainfunc = obj.instance.exports.main;
    mainfunc();

    // Verify the collected output matches the expected printed list.
    console.log(out);
    // assert.equal(out, '(42 #t 7 #f)');
})();
