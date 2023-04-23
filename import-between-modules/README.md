Example of calling a function in one wasm module from another wasm module, by
exporting and re-importing it in the hosting JS.

Note that this is a very simplistic version of *linking* two WASM modules
together. As far as I know, the concept of linking WASM files is not
standardized, but some tools exist that can help do "real" linking. To learn
more about this, read [WebAssembly Object File
Linking](https://github.com/WebAssembly/tool-conventions/blob/main/Linking.md)
and the [wasm-ld tool](https://lld.llvm.org/WebAssembly.html).
