;; This module exports a trivial `times2` function.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (func (export "times2") (param i32) (result i32)
        (i32.add (local.get 0) (local.get 0))
    )
)