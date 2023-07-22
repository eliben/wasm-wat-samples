Demonstrates how to use WASI APIs in WAT.

This sample requires a relatively recent version of Node.js (at least 20.0.0),
in which case no special `--experimental-...` flags are required to run `node`.

It can also be run with another WASM runtime that supports WASI, e.g.
`wasmtime`:

```
  $ wasmtime run write.wasm
```
