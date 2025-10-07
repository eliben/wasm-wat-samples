;; Basic "add" example.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (type $Pair (struct
        (field (mut i32))
        (field (mut i32))
    ))
    (type $PairArray (array (mut (ref null $Pair))))

    ;; A mutable global that holds a nullable ref to our array type.
    (global $hold (mut (ref null $PairArray)) (ref.null $PairArray))

    ;; alloc(N): allocate N Pair structs into an array and store in a global
    (func (export "alloc") (param $n i32)
        (local $i i32)
        (local $arr (ref $PairArray))
        (local.set $arr (array.new_default $PairArray (local.get $n)))

        ;; while (i < n) { arr[i] = new Pair(1,2); i++; }
        (block $exit
          (loop $loop
            ;; if (i >= n) break;
            (br_if $exit (i32.ge_u (local.get $i) (local.get $n)))

            ;; arr[i] = Pair{1,2}
            (array.set $PairArray
              (local.get $arr)
              (local.get $i)
              (struct.new $Pair (i32.const 1) (i32.const 2)))

            ;; i++
            (local.set $i (i32.add (local.get $i) (i32.const 1)))

            ;; continue
            (br $loop)
          )
        )
        (global.set $hold (local.get $arr))
    )

    ;; drop_all(): clear the only strong ref so the array + its structs are unreachable
    (func (export "drop_all")
        (global.set $hold (ref.null $PairArray))
    )
)

