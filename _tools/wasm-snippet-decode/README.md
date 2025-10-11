To run:

    $ uv run write.py

To type check:

    $ uvx ty check

The `write.py` script invokes `wasm-tools print` on the WASM binary it produces
(if `wasm-tools` is installed). It's also possible to manually invoke
`wasm-tools dump` for an annotated dump of the binary, showing the instructions
it represents.

