;; Shows how to use reference types like externref.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (table $table 10 externref)

    ;; Roundtrips its parameter of an opaque externref back to the caller.
    (func (export "roundtrip") (param externref) (result (ref null extern))
        local.get 0
    )

    ;; Saves its parameter in a slot in the table.
    (func (export "saveref") (param $x externref)
        (table.set $table (i32.const 8) (local.get $x))
    )

    ;; Loads from a table slot and returns.
    (func (export "loadref") (result externref)
        (table.get $table (i32.const 8))
    )
)
