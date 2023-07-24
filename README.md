# WebAssembly WAT samples

Some sample **W**eb**A**ssembly **T**ext programs.

[WebAssembly defines](https://en.wikipedia.org/wiki/WebAssembly) a portable
binary-code format and a corresponding **text format** for executable programs
as well as software interfaces for facilitating interactions between such
programs and their host environment.

The text format (WAT) is, essentially, an assembly language. While most people
will not write WAT directly (just as most programmers don't write assembly code
directly), familiarity this format is important if you seek a deep understanding
of WASM mechanisms and related toolchains.

## How to run these samples

Unless otherwise stated, each sample consists of a single `.wat` file and an
accompanying `test.js` file. When the setup is more complicated, the directory's
own README will have additional information.

First, start by compiling the WAT file to WASM with [wabt](https://github.com/WebAssembly/wabt)
or some other WASM toolchain:

```
$ wat2wasm somefile.wat
```

This creates a `somefile.wasm` binary, which `test.js` expects to find in its
own directory. To load and test the WASM, you'll need a recent
Node.js installed, and run:

```
$ node test.js
```

This will typically emit some output; if the loading failed or the loaded WASM
behaves unexpectedly, the `test.js` script will report an error.

## WASI documentation

Useful sources of documentation about WASI host calls:

* [Preview 1 ABI](https://github.com/WebAssembly/WASI/blob/main/legacy/preview1/docs.md)
* [wasi-libc sources](https://github.com/WebAssembly/wasi-libc); in particular,
  the [wasi/api.h header](https://github.com/WebAssembly/wasi-libc/blob/main/libc-bottom-half/headers/public/wasi/api.h)
