// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/gc-cast-type.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    const v = obj.instance.exports.make_i31(42);
    const tt = obj.instance.exports.make_TT(100, 200);
    const t2 = obj.instance.exports.make_T2(3.14159)

    const result_v = obj.instance.exports.report(v);
    const result_tt = obj.instance.exports.report(tt);
    const result_t2 = obj.instance.exports.report(t2);

    assert.equal(result_v, 43);
    assert.equal(result_tt, 300);
    assert.equal(result_t2, -1);
})();
