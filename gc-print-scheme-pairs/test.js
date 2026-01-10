// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/gc-print-scheme-pairs.wasm');

    // out will collect the printed output.
    let out = '';
    const importObject = {
        env: {
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
    assert.equal(out, `(42 #t 7 #f)
(foobar 99 aragorn)
(1 2 . 3)
((10 20) (#t #f))
((10 20) ())
`)
})();
