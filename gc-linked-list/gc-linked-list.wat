;;
;; TODO add an int field, then code to walk and sum them all up
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (type $Node
        (struct
            (field $val i32)
            (field $next (ref null $Node))))

    (global $globalhead (mut (ref null $Node)) (ref.null $Node))
    (export "globalhead" (global $globalhead))

    ;; TODO: also return it... so we can check the opaque passing thru host
    (func (export "makelist")
        (local $i i32)    ;; $i = 0
        (loop $loop
            (global.set $globalhead
                (struct.new $Node
                    (local.get $i)
                    (global.get $globalhead)))
            (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br_if $loop
            (i32.le_u (local.get $i) (i32.const 100)))
        )
    )

    (func (export "addup") (result i32)
        (local $lst (ref null $Node))
        (local $sum i32)

        (local.set $lst (global.get $globalhead))
        (loop $loop (block $breakloop
            (local.get $lst)
            br_on_null $breakloop
            (local.set 
                $sum
                (i32.add
                    (local.get $sum)
                    (struct.get $Node $val (local.get $lst))))
            (local.set $lst (struct.get $Node $next (local.get $lst)))
            br $loop
        ))
        (local.get $sum)
    )
)
