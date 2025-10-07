// JS loader and tester for the sample.
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

    // allocate ~1e6 small GC objects (tune N to your machine)
    obj.instance.exports.alloc(1_000_000);
    snap('after alloc (live)');

    // explicitly request V8 GC (allowed because of --expose-gc)
    global.gc();
    snap('after gc (still live, held by wasm global)');

    // drop the only reference inside Wasm so everything becomes unreachable
    obj.instance.exports.drop_all();
    snap('after drop (unreachable, before gc)');

    // force another GC to reclaim them now
    global.gc();
    snap('after gc (reclaimed)');
})();
