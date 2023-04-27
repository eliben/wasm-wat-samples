;; Examples of declaring and using local values.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Returns the default value of an i32 local. Locals are guaranteed by
    ;; the WASM spec to be initialized to their zero value (0 for i32).
    (func (export "return_default") (result i32)
        (local $x i32)
        (local.get $x)
    )

    ;; Shows how to access unnamed locals. Unnamed locals (including function
    ;; params) get implicit indices starting with 0.
    (func (export "unnamed_locals") (param i32) (param i32) (result i32 i32 i32)
        (local i32)
        (local.set 2 (i32.const 44))

        ;; This places the first parameter on the stack, then the next parameter
        ;; and finally the local defined in this function.
        (local.get 0)
        (local.get 1)
        (local.get 2)
    )

    ;; Mixing named and unnamed locals. This isn't recommended in real code,
    ;; but it's educational to know what happens.
    (func (export "some_unnamed") (param i32) (param $a i32) (result i32 i32 i32 i32)
        (local $x i32)
        (local i32)

        ;; Index 0 refers to the first parameter; since the next parameter
        ;; and the first local are named, indices 1 and 2 aren't used, and
        ;; index 3 refers to the second parameter.
        (local.set $x (i32.const 77))
        (local.set 3 (i32.const 44))

        (local.get 0)
        (local.get $a)
        (local.get $x)
        (local.get 3)
    )

    ;; We can also refer to named locals (and params) using their explicit
    ;; index, instead of their declared names.
    (func (export "named_by_index") (param $a i32) (param $b i32) (result i32 i32 i32)
        (local $x i32)
        (local.set 2 (i32.const 88))

        (local.get 0)
        (local.get 1)
        (local.get 2)
    )
)
