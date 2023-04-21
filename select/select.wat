;; Basic example of using the WASM `select` construct.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; add_or_sub(a, b, control): if control >= 0, returns a+b. Otherwise
    ;; returns a-b.
    (func $add_or_sub (export "add_or_sub")
        (param $a i32) (param $b i32) (param $control i32)
        (result i32)

        ;; select returns its first argument if the third is true, or the
        ;; second argument if the third is false.
        (select
            (i32.add (local.get $a) (local.get $b))
            (i32.sub (local.get $a) (local.get $b))
            (i32.ge_s (local.get $control) (i32.const 0))
        )
    )
)
