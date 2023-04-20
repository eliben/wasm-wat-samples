;; Basic "add" example.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; is_prime(n) takes a (positive) number and returns 1 if this number is
    ;; prime, 0 if it's composite.
    (func $add (export "add") (param $a i32) (param $b i32) (result i32)
        (i32.add (local.get $a) (local.get $b))
    )
)
