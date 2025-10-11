;; Dynamically checking types of ref, ref casts and using i31s.
;;
;; This sample defines an array of generic (ref eq) references, and populates
;; it with a mixture of i31 refs and struct refs. Another function iterates
;; over the array, checking the type of each element, and summing up the
;; values of the i31s only.
;;
;; i31 refs are a special kind of reference that can hold small integers
;; (31-bit signed integers) directly in the reference value, without
;; requiring a separate heap allocation. This makes them very efficient for
;; use cases where small integers are needed.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; A simple struct type with two mutable f64 fields
    (type $Point (struct (field (mut f64)) (field (mut f64))))

    ;; An array of refs, can hold any (ref eq)
    (type $Arr (array (ref eq)))

    ;; Build array of refs, a few of which are i31s
    (func (export "make") (result (ref $Arr))
        (array.new_fixed $Arr 5
            (ref.i31 (i32.const 7))
            (struct.new $Point (f64.const 1) (f64.const 2))
            (ref.i31 (i32.const 100))
            (ref.i31 (i32.const 20))
            (struct.new $Point (f64.const 3) (f64.const 4)))
    )

    ;; Sum all i31 elements in the array; ignore non-i31 entries
    (func (export "sum_i31s") (param $a (ref $Arr)) (result i32)
        (local $i i32)
        (local $n i32)
        (local $acc i32)
        (local $tmp (ref eq))

        ;; n = len(arr), acc is our accumulator
        (local.set $n (array.len (local.get $a)))
        (local.set $i (i32.const 0))
        (local.set $acc (i32.const 0))

        ;; for i = 0; i < n; i++
        (loop $addloop (block $breakloop
            (i32.ge_s (local.get $i) (local.get $n))
            br_if $breakloop

            ;; tmp = a[i]
            (local.set $tmp (array.get $Arr (local.get $a) (local.get $i)))

            ;; if tmp is i31: acc += i31.get_u(tmp)
            (ref.test (ref i31) (local.get $tmp))
            if
                (local.set $acc
                    (i32.add
                        (local.get $acc)
                        (i31.get_u
                            (ref.cast (ref i31) (local.get $tmp)))))
            end

            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            br $addloop
        ))
        (local.get $acc)
    )
)
