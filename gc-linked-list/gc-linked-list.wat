;; Linked list using WASM GC reference types.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Node type: struct with the fields {val: i32, next: *Node}
    (type $Node
        (struct
            (field $val i32)
            (field $next (ref null $Node))))

    ;; Creates and returns a linked list with values [0...$n]
    (func (export "makelist") (param $n i32) (result (ref null $Node))
        (local $i i32)    ;; $i = 0
        (local $lst (ref null $Node))

        (local.set $lst (ref.null $Node))

        (loop $loop
            (local.set $lst
                (struct.new $Node
                    (local.get $i)
                    (local.get $lst)))
            (local.set $i (i32.add (local.get $i) (i32.const 1)))
        (br_if $loop
            (i32.le_u (local.get $i) (local.get $n)))
        )
        
        local.get $lst
    )

    ;; Adds up the values in the given list and returns the sum
    (func (export "addup") (param $lst (ref null $Node)) (result i32)
        (local $sum i32)

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
