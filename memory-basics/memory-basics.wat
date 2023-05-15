;; Some basics of creating, initializing and growing a WASM linear memory.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Declare linear memory with initial size of 1 page (64 KiB) and maximal
    ;; size of 100 pages, and export it to host.
    ;;
    ;; According to the WASM spec (2.5.8), the initial contents of a memory
    ;; are zero bytes.
    (memory (export "memory") 1 100)

    ;; Initialize 16 bytes with hex data, starting at offset 0.
    (data (i32.const 0x0000)
        "\67\68\69\70\AA\FF\DF\CB"
        "\12\A1\32\B3\A5\1F\01\02"
    )

    ;; Initialize 8 bytes, starting at offset 0x20.
    (data (i32.const 0x020)
        "\01\03\05\07\09\0B\0D\0F"
    )

    ;; Grow the linear memory by $delta pages; return the size (in pages) of
    ;; memory before it was increased.
    (func (export "wasm_grow") (param $delta i32) (result i32)
        (memory.grow (local.get $delta))
    )

    ;; Report the size of wasm's linear memory, in pages.
    (func (export "wasm_size") (result i32)
        memory.size
    )

    ;; Fill memory starting at $start with $n instance of byte $val.
    (func (export "wasm_fill") (param $start i32) (param $val i32) (param $n i32)
        (memory.fill (local.get $start) (local.get $val) (local.get $n))
    )
)
