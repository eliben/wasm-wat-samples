;; Shows how to emulate Scheme-like pairs/lists with WASM GC structs/refs.
;; Also shows how to print such structures from within WASM, using minimal
;; IO imports from the host.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (import "env" "write_char" (func $write_char (param i32)))
    (import "env" "write_i32" (func $write_i32 (param i32)))

    ;; ints are represented as ref i31; bools and pairs get dedicated structs.

    (type $Bool (struct 
        (field i32)  ;; 0 = #f, nonzero = #t
    ))

    (type $Pair (struct 
        (field (ref null eq))   ;; car
        (field (ref null eq))   ;; cdr
    ))

    (func $emit (param $c i32)
        (call $write_char (local.get $c))
    )

    (func $emit_lparen  (call $emit (i32.const 40))) ;; '('
    (func $emit_rparen  (call $emit (i32.const 41))) ;; ')'
    (func $emit_space   (call $emit (i32.const 32))) ;; ' '
    (func $emit_newline (call $emit (i32.const 10))) ;; '\n'

    (func $emit_bool (param $b (ref $Bool))
        (call $emit (i32.const 35)) ;; '#'
        (if (i32.eqz (struct.get $Bool 0 (local.get $b)))
            (then (call $emit (i32.const 102))) ;; 'f'
            (else (call $emit (i32.const 116))) ;; 't'
        )
    )

    (func $emit_value (param $v (ref null eq))
        ;; nil
        (if (ref.is_null (local.get $v))
            (then
                (call $emit_lparen)
                (call $emit_rparen)
                (return)
            )
        )

        ;; integer
        (if (ref.test (ref i31) (local.get $v))
            (then
                (call $write_i32 (i31.get_s (ref.cast (ref i31) (local.get $v))))
                (return)
            )
        )

        ;; bool
        (if (ref.test (ref $Bool) (local.get $v))
            (then
                (call $emit_bool (ref.cast (ref $Bool) (local.get $v)))
                (return)
            )
        )

        ;; pair
        (if (ref.test (ref $Pair) (local.get $v))
            (then
                (call $emit_pair (ref.cast (ref $Pair) (local.get $v)))
                (return)
            )
        )

        ;; unknown type: emit '?'
        (call $emit (i32.const 63))
    )

    (func $emit_pair (param $p (ref $Pair))
        (local $cur (ref null $Pair))
        (local $cdr (ref null eq))

        (call $emit_lparen)
        (local.set $cur (local.get $p))

        (loop $loop (block $breakloop
            ;; print car
            (call $emit_value (struct.get $Pair 0 (local.get $cur)))

            (local.set $cdr (struct.get $Pair 1 (local.get $cur)))
            
            ;; end of list?
            (br_if $breakloop (ref.is_null (local.get $cdr)))

            ;; cdr is another pair, continue loop
            (if (ref.test (ref $Pair) (local.get $cdr))
                (then
                    (call $emit_space)
                    (local.set $cur (ref.cast (ref $Pair) (local.get $cdr)))
                    br $loop
                )
                (else
                    ;; cdr is not a pair, print dot and the cdr value, then end
                    (call $emit (i32.const 32)) ;; space
                    (call $emit (i32.const 46)) ;; '.'
                    (call $emit (i32.const 32)) ;; space
                    (call $emit_value (local.get $cdr))
                    br $breakloop
                )
            )
        ))

        (call $emit_rparen)
    )

    (func $mk_true (result (ref $Bool))
        (struct.new $Bool (i32.const 1))
    )

    (func $mk_false (result (ref $Bool))
        (struct.new $Bool (i32.const 0))
    )

    (func $mk_int (param $x i32) (result (ref i31))
        (ref.i31 (local.get $x))
    )

    (func $cons (param $a (ref null eq)) (param $b (ref null eq)) (result (ref $Pair))
        (struct.new $Pair (local.get $a) (local.get $b))
    )

    (func (export "main")
        ;; Create a proper list of a few ints and bools:
        (local $lst (ref null eq))
        (local.set $lst
            (call $cons
                (call $mk_int (i32.const 42))
                (call $cons
                    (call $mk_true)
                    (call $cons
                        (call $mk_int (i32.const 7))
                        (call $cons
                            (call $mk_false)
                            (ref.null eq))))))
        
        (call $emit_value (local.get $lst))
        (call $emit_newline)

        ;; Create a list with a dotted pair at the end
        (local.set $lst
            (call $cons
                (call $mk_int (i32.const 1))
                (call $cons
                    (call $mk_int (i32.const 2))
                    (call $mk_int (i32.const 3)))))
        
        (call $emit_value (local.get $lst))
        (call $emit_newline)

        ;; Nested list of lists
        (local.set $lst
            (call $cons
                (call $cons
                    (call $mk_int (i32.const 10))
                    (call $cons
                        (call $mk_int (i32.const 20))
                        (ref.null eq)))
                (call $cons
                    (call $cons
                        (call $mk_true)
                        (call $cons
                            (call $mk_false)
                            (ref.null eq)))
                    (ref.null eq))))

        (call $emit_value (local.get $lst))
        (call $emit_newline)

        ;; Nested list with an empty list
        (local.set $lst
            (call $cons
                (call $cons
                    (call $mk_int (i32.const 10))
                    (call $cons
                        (call $mk_int (i32.const 20))
                        (ref.null eq)))
                (call $cons
                    (ref.null eq)
                    (ref.null eq))))

        (call $emit_value (local.get $lst))
        (call $emit_newline)
    )
)
