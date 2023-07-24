Demonstrates how to use WASI APIs to read a file from WASM.

The WASM module in `readfile.wat` expects to be able to find its input file
`sample.txt` in the root directory of its sandbox: `/`.

Usually, WASM modules will scan through a list of sandbox directories to find
which directories are available. In this example, we assume only the `/`
directory is mapped; therefore, the WASM code assumes it can find it at the
first file descriptor available for mapping: 3.

After compiling the WAT file to `readfile.wasm`, this sample can be tested
with different WASM runtimes. The usual `node test.js` invocation works, but
also wasmtime:

```
$ wasmtime run --mapdir /::. readfile.wasm
```

And wazero:

```
$ wazero run -mount .:/ readfile.wasm
```

The syntax of directory mapping/mounting in these runtimes is different; what's
important is to map the current working directory of the host (`.`) to the
root sandbox directory of the WASM module (`/`).

A very useful debugging option for `wazero run` is `-hostlogging filesystem`.
It logs the WASI host calls the module invokes, with their parameters and
return values.
