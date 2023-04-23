// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const fs = require('fs');
const assert = require('node:assert');

(async () => {
    const mod1 = fs.readFileSync(__dirname + '/mod1.wasm');
    const mod2 = fs.readFileSync(__dirname + '/mod2.wasm');

    // Instantiate mod1, so we can grab its exported times2 function.
    let mod1obj = await WebAssembly.instantiate(new Uint8Array(mod1));

    const importObject = {
        env: {
            times2: mod1obj.instance.exports.times2
        }
    }

    // Instantiate mod1, passing the import object that has env.times2
    let mod2obj = await WebAssembly.instantiate(new Uint8Array(mod2), importObject);
    let twiceplus5 = mod2obj.instance.exports.twiceplus5;

    console.log('2*16+5 =', twiceplus5(16));

    assert.equal(twiceplus5(0), 5);
    assert.equal(twiceplus5(1), 7);
    assert.equal(twiceplus5(10), 25);
    assert.equal(twiceplus5(-92), -179);
})();

