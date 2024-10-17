;; Basic "add" example.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Memory buffer with data imported from the host.
    (import "env" "buffer" (memory 80))

    (import "env" "log_i32" (func $log_i32 (param i32)))
    (import "env" "log_4xi32" (func $log_4xi32 (param i32 i32 i32 i32)))

    ;; vcount counts the number of occurrences of a given value in a buffer.
    ;; the buffer is specified as a start address and the count of i32 values
    ;; to scan. This function assumes that count is a multiple of 4.
    (func $vcount (export "vcount") (param $start i32) (param $count i32) (param $val i32) (result i32)
        (local $v v128)
        (local $totalcount v128)
        (local $vals v128)
        (local $i i32)
        (local $addr i32)

        ;; Splat val into all lanes of vals, for SIMD comparisons.
        (local.set $vals (i32x4.splat (local.get $val)))

        ;; for (i = 0; i < count; i += 4)
        (local.set $i (i32.const 0))
        (loop $countloop (block $breakcountloop
            (br_if $breakcountloop (i32.ge_s (local.get $i) (local.get $count)))

            ;; Load the next 4 i32 values into v
            (local.set $v
                (v128.load
                    (i32.add
                        (local.get $start)
                        (i32.mul (i32.const 4) (local.get $i)))))

            ;; Compare v with vals; the result is a vector where each lane
            ;; is 0 if the lane != val, and 0xffffffff if the lane == val.
            (local.set $v (i32x4.eq (local.get $v) (local.get $vals)))

            ;; ... using the fact that 0xffffffff is -1 when interpreted as a
            ;; signed integer, accumulate the number of matches in totalcount.
            (local.set $totalcount (i32x4.add (local.get $totalcount) (local.get $v)))

            (local.set $i (i32.add (local.get $i) (i32.const 4)))
            br $countloop
        ))

        ;; Negate totalcount so we get a positive total count in each lane
        (local.set $totalcount (i32x4.neg (local.get $totalcount)))

        ;; Sum the lanes of totalcount to get the total count
        (i32.add
            (i32.add
                (i32x4.extract_lane 0 (local.get $totalcount))
                (i32x4.extract_lane 1 (local.get $totalcount)))
            (i32.add
                (i32x4.extract_lane 2 (local.get $totalcount))
                (i32x4.extract_lane 3 (local.get $totalcount))))
    )

    (func $vlog (param $a v128)
        (call $log_4xi32
            (i32x4.extract_lane 0 (local.get $a))
            (i32x4.extract_lane 1 (local.get $a))
            (i32x4.extract_lane 2 (local.get $a))
            (i32x4.extract_lane 3 (local.get $a)))
    )
)
