// JS loader and tester for the sample.
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
const assert = require('node:assert');
const fs = require('fs');

// Create a memory object for WASM
const memory = new WebAssembly.Memory({ initial: 1 });

// Logging function ($log) called from WebAssembly
function consoleLogString(offset, length) {
  const bytes = new Uint8Array(memory.buffer, offset, length);
  const string = new TextDecoder("utf8").decode(bytes);
  console.log(string);
}

(async () => {
    // Load the WASM file and instantiate it.
    let importObject = {
        console: { log: consoleLogString },
        js: { mem: memory },
    };

    const bytes = fs.readFileSync(__dirname + '/memory-import.wasm');
    let obj = await WebAssembly.instantiate(new Uint8Array(bytes), importObject);

    let writeHi = obj.instance.exports.writeHi;
    writeHi();
})();
