;; Example of reference type tests and casts.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (type $TT (struct (field i32) (field i32)))
    (type $T2 (struct (field f64)))

    (func (export "make_i31") (param $val i32) (result anyref)
        (ref.i31 (local.get $val))
    )

    (func (export "make_TT") (param $f1 i32) (param $f2 i32) (result anyref)
        (struct.new $TT (local.get $f1) (local.get $f2))
    )

    (func (export "make_T2") (param $f1 f64) (result anyref)
        (struct.new $T2 (local.get $f1))
    )

    ;; Takes a value of "anyref" type, which is a synonym for (ref null any).
    ;; Based on the value's runtime (dynamic) type, do different things.
    ;; - If it's a (ref i31), return the underlying value + 1
    ;; - If it's a (ref $TT), return the sum of the fields
    ;; - Otherwise return -1
    (func (export "report") (param $r anyref) (result i32)
        (ref.test (ref i31) (local.get $r))
        if 
            (i32.add (i32.const 1) (i31.get_u (ref.cast (ref i31) (local.get $r))))
            return
        else
            (ref.test (ref $TT) (local.get $r))
            if
                (i32.add
                  (struct.get $TT 0 (ref.cast (ref $TT) (local.get $r)))
                  (struct.get $TT 1 (ref.cast (ref $TT) (local.get $r))))
                return
            end
        end
        (i32.const -1)
    )
)
