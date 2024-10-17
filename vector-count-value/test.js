// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/vcount.wasm');

    const memory = new WebAssembly.Memory({ initial: 80 });
    const mem_i32 = new Int32Array(memory.buffer);

    let importObject = {
        env: {
            log_i32: function (n) {
                console.log(`log i32: ${n}`);
            },

            log_4xi32: function(n0, n1, n2, n3) {
                console.log(`log 4xi32: ${n0} ${n1} ${n2} ${n3}`);
            },

            buffer: memory
        }
    };

    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);
    let vcount = obj.instance.exports.vcount;

    // We pass a byte buffer to WASM; in JS, it's convenient to have an
    // Int32Array view on it.
    //
    // memOffset is the offset in mem_i32 where our data starts.
    const memOffset = 128;

    // Initialize data starting at memOffset.
    let initArr = [15, 19, 27, 19, 19, 20, 11, 9, 3, 18, 9, 19, 1, 2, 3, 4];
    mem_i32.set(initArr, memOffset);

    let count = vcount(memOffset * 4, initArr.length, 19);
    console.log('count:', count);

    dotest = (arr, val) => {
        mem_i32.set(arr, memOffset);
        let got =vcount(memOffset * 4, arr.length, val);
        let want = arr.filter(x => x === val).length;
        assert.strictEqual(got, want);
    }

    dotest([], 5);
    dotest([1, 2, 3, 4], 4);
    dotest([1, 4, 3, 4], 4);
    dotest([4, 4, 3, 4], 4);
    dotest([4, 4, 3, 4, 8, 4, 2, 1], 4);
    dotest([4, 4, 3, 4, 8, 4, 3, 1], 3);
    dotest([4, 4, 3, 4, 8, 4, 2, 3], 3);
    dotest([4, 4, 3, 4, 8, 4, 2, 1, 9, 4, 8, 4], 4);

    dotest([1, 2, 3, 4, 5, 6, 7, 8], 5);
})();


