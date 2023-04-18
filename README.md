# wasm-wat-samples

Some sample **W**eb**A**ssembly **T**ext programs.

## How to run these samples

Unless otherwise stated, each sample consists of a single `.wat` file and an
accompanying `test.js` file. When the setup is more complicated, the directory's
own README will have explain what to do.

First, start by compiling the WAT file to WASM with [wabt](https://github.com/WebAssembly/wabt)
or some other WASM toolchain:

```
$ wat2wasm somefile.wat
```

This creates a `somefile.wasm` binary, which `test.js` expects to find in its
own directory. To load and test the WASM, you'll need a reasonably recent
Node.js installed, and run:

```
$ node test.js
```

This will typically emit some output; if the loading failed or the loaded WASM
behaves unexpectedly, the `test.js` script will report an error.
