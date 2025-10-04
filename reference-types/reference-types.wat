;; Shows how to use reference types like externref.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (table $table 10 externref)

    ;; Roundtrips its parameter of an opaque externref back to the caller.
    ;; Also shows that "(ref null extern)" is equivalent to "externref".
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

    (type $int2int (func (param i32) (result i32)))

    ;; Add $inc to the function table; 'declare' means that references to
    ;; $inc will go here.
    (elem declare funcref (ref.func $inc))

    ;; Example of typed references; we can use them directly for higher-order
    ;; functions.
    ;;   $hof takes a function and calls it via call_ref.
    ;;   $inc is a function of the right type that can be passed to $hof
    (func $hof (param $f (ref $int2int)) (result i32)
        (i32.add
            (i32.const 10)
            (call_ref $int2int (i32.const 42) (local.get $f)))
    )

    (func $inc (param $i i32) (result i32)
        (i32.add (local.get $i) (i32.const 1))
    )

    (func (export "caller") (result i32)
        (call $hof (ref.func $inc))
    )
)
