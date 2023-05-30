;; Shows how to use the SIMD swizzle instruction to reorder lanes in a vector,
;; by performing an endianness flip of words.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Memory buffer with data imported from the host.
    (import "env" "buffer" (memory 80))

    ;; Flips the endianness of the words in the 16-byte buffer at the given
    ;; memory offset.
    ;; Assumes the buffer contains four 4-byte words. The result is written
    ;; in-place into the same memory offset.
    (func $endianflip (export "endianflip") (param $offset i32)
        (v128.store
            (local.get $offset)
            (i8x16.swizzle
                (v128.load (local.get $offset))
                (v128.const i8x16 3 2 1 0 7 6 5 4 11 10 9 8 15 14 13 12)))
    )
)
