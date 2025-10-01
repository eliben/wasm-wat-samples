;; Example of 64-bit memory address space (introduced in WASM 3.0)
;; This is similar to memory-basics, but with i64 types.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Use the explicit memory type specifier to mark memory as i64
    ;;
    ;; The maximal size of 250000 pages wouldn't work with the default i32
    ;; time because it implies 250000 * 64k ~ 16 GiB of memory, which is above
    ;; the 4 GiB limit allowed for i32 memories.
    (memory (export "memory") i64 2 250000)

    ;; Initialize 16 bytes with hex data, starting at offset 0.
    ;; We have to use matching const type for the address, so i64 here.
    (data (i64.const 0x0000)
        "\67\68\69\70\AA\FF\DF\CB"
        "\12\A1\32\B3\A5\1F\01\02"
    )

    ;; Initialize 8 bytes, starting at offset 0x20.
    (data (i64.const 0x020)
        "\01\03\05\07\09\0B\0D\0F"
    )

    ;; Report the size of wasm's linear memory, in pages.
    (func (export "wasm_size") (result i64)
        memory.size
    )

    ;; Fill memory starting at $start with $n instance of byte $val.
    (func (export "wasm_fill") (param $start i64) (param $val i32) (param $n i64)
        (memory.fill (local.get $start) (local.get $val) (local.get $n))
    )

    ;; ... Other stuff from memory-basics will also work, with adjusted pointer
    ;; sizes to i64.
)
