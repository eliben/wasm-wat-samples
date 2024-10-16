;; 
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Memory buffer with data imported from the host.
    (import "env" "buffer" (memory 80))

    (import "env" "log_i32" (func $log_i32 (param i32)))

    ;; vmin returns the minimal value in a memory array of i32 values.
    ;; start is the offset in memory where this array starts.
    ;; count is the number of i32 values - each value is 4 bytes. We assume
    ;; count >= 4 and is a multiple of 4.
    (func $vmin (export "vmin") (param $start i32) (param $count i32) (result i32)
        (local $v v128)
        (local $i i32)
        (local $result i32)
        (local $addr i32)

        ;; init v with the first 4 i32 values in the array
        (local.set $v (v128.load (local.get $start)))

        ;; for (i = 0; i < count; i += 4)
        ;; i is the index of i32s in the array
        (local.set $i (i32.const 0))
        (loop $minloop (block $breakminloop
            (br_if $breakminloop (i32.ge_s (local.get $i) (local.get $count)))

            ;; Load the next 4 i32 values into a vector, and vector-min them
            ;; into v.
            (local.set $addr
                (i32.add
                    (local.get $start)
                    (i32.mul (i32.const 4) (local.get $i))))
            (call $log_i32 (local.get $addr))

            (local.set $v
                (i32x4.min_s
                    (local.get $v)
                    (v128.load (local.get $addr))))

            (local.set $i (i32.add (local.get $i) (i32.const 4)))
            br $minloop
        ))

        ;; Scalar calculation: the minimal value among vector $result's lanes.
        (local.set $result (i32x4.extract_lane 0 (local.get $v)))
        (local.set $result
            (call $i32min (local.get $result) (i32x4.extract_lane 1 (local.get $v))))
        (local.set $result
            (call $i32min (local.get $result) (i32x4.extract_lane 2 (local.get $v))))
        (local.set $result
            (call $i32min (local.get $result) (i32x4.extract_lane 3 (local.get $v))))
        
        (local.get $result)
    )

    ;; i32min returns min(a, b)
    (func $i32min (export "i32min") (param $a i32) (param $b i32) (result i32)
        (select 
            (local.get $a)
            (local.get $b)
            (i32.lt_s (local.get $a) (local.get $b)))
    )

    ;; 
    (func $vargmin (export "vargmin") (param $offset i32)
        (local $aa v128)
        (local $bb v128)
        (local $mask v128)
        
        (local.set $aa (v128.load (local.get $offset)))
        (local.set $bb (v128.load (i32.add (local.get $offset) (i32.const 16))))

        (local.set $mask (i8x16.lt_s (local.get $aa) (local.get $bb)))

        (v128.store
            (i32.add (local.get $offset) (i32.const 32))
            (v128.bitselect (local.get $aa) (local.get $bb) (local.get $mask)))

        ;; (v128.store
        ;;     (i32.add (local.get $offset) (i32.const 32))
        ;;     (i8x16.lt_s (local.get $aa) (local.get $bb)))
    )
)
