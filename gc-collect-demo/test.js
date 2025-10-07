// JS loader and tester for the sample.
//
// Run this with --expose-gc to see the Node.js GC in action.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');
const v8 = require('node:v8');

function snap(tag) {
  const mu = process.memoryUsage();
  const hs = v8.getHeapStatistics();
  console.log(tag, {
    rssMB: (mu.rss / 1e6).toFixed(1),
    heapUsedMB: (mu.heapUsed / 1e6).toFixed(1),
    heapTotalMB: (mu.heapTotal / 1e6).toFixed(1),
    v8HeapMB: (hs.total_heap_size / 1e6).toFixed(1),
  });
}

(async () => {
    // Load the WASM file and instantiate it.
    const bytes = fs.readFileSync(__dirname + '/gc-collect-demo.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes));

    snap('start');

    obj.instance.exports.alloc(1_000_000);
    snap('after alloc (live)');

    // Test the array was initialized properly
    let elem2 = obj.instance.exports.get(2);
    assert.deepEqual(elem2, [1, 2]);

    if (global.gc === undefined) {
        console.log("Run with --expose-gc to observe collection");
    } else {
        global.gc();
        snap('after gc (still live, held by wasm global)');

        // drop the only reference inside Wasm so everything becomes unreachable
        obj.instance.exports.drop_all();
        snap('after drop (unreachable, before gc)');

        // force another GC to reclaim them now
        global.gc();
        snap('after gc (reclaimed)');
    }
})();
