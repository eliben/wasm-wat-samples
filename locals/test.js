// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/locals.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    let result = obj.instance.exports.return_default();
    console.log(result);

    assert.equal(result, 0);

    let r1 = obj.instance.exports.unnamed_locals(11, 22);
    assert.deepEqual(r1, [11, 22, 44]);

    let r2 = obj.instance.exports.some_unnamed(11, 22);
    assert.deepEqual(r2, [11, 22, 77, 44]);

    let r3 = obj.instance.exports.named_by_index(11, 22);
    assert.deepEqual(r3, [11, 22, 88]);

    let r4 = obj.instance.exports.multi_decl(11, 22);
    assert.deepEqual(r4, [11, 22, 33, 44]);
})();


