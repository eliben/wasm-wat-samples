;; Shows how to use multiple memories from wasm.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Declare two memories, each with a single page.
    (memory $memX 1)
    (memory $memY 1)

    (export "memX" (memory $memX))
    (export "memY" (memory $memY))

    ;; sum_some_items adds up i32s loaded at offsets 4 and 8 in memY
    (func (export "sum_some_items") (result i32)
        (i32.add
            (i32.load $memY (i32.const 4))
            (i32.load $memY (i32.const 8)))
    )

    ;; docopy copies $n bytes from memX to memY (starting with offset 0).
    (func (export "docopy") (param $n i32)
        (memory.copy
            $memY $memX
            (i32.const 0) (i32.const 0) (local.get $n))
    )
)
