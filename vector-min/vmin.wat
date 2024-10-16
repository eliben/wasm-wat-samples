;; vmin (minimal value in an array) and vargmin (index of minimal value in an
;; array) using SIMD in WebAssembly.
;;
;; Based on http://0x80.pl/notesen/2018-10-03-simd-index-of-min.html
;;
;; Eli Bendersky [https://eli.thegreenplace.net] This code is in the public
;; domain.
(module
    ;; Memory buffer with data imported from the host.
    (import "env" "buffer" (memory 80))

    (import "env" "log_i32" (func $log_i32 (param i32)))
    (import "env" "log_4xi32" (func $log_4xi32 (param i32 i32 i32 i32)))

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

        ;; for (i = 4; i < count; i += 4)
        ;; i is the index of i32s in the array
        (local.set $i (i32.const 4))
        (loop $minloop (block $breakminloop
            (br_if $breakminloop (i32.ge_s (local.get $i) (local.get $count)))

            ;; Load the next 4 i32 values into a vector, and vector-min them
            ;; into v.
            (local.set $addr
                (i32.add
                    (local.get $start)
                    (i32.mul (i32.const 4) (local.get $i))))

            (local.set $v
                (i32x4.min_s
                    (local.get $v)
                    (v128.load (local.get $addr))))

            (local.set $i (i32.add (local.get $i) (i32.const 4)))
            br $minloop
        ))

        ;; Scalar reduction: the minimal value among vector $result's lanes.
        (local.set $result (i32x4.extract_lane 0 (local.get $v)))
        (local.set $result
            (call $i32min (local.get $result) (i32x4.extract_lane 1 (local.get $v))))
        (local.set $result
            (call $i32min (local.get $result) (i32x4.extract_lane 2 (local.get $v))))
        (local.set $result
            (call $i32min (local.get $result) (i32x4.extract_lane 3 (local.get $v))))
        
        (local.get $result)
    )

    ;; vargmin returns the index of the minimal value in a memory array of
    ;; i32 values.
    ;; start is the offset in memory where this array starts.
    ;; count is the number of i32 values - each value is 4 bytes. We assume
    ;; count >= 4 and is a multiple of 4.
    (func $vargmin (export "vargmin") (param $start i32) (param $count i32) (result i32)
        (local $v v128)
        (local $indices v128)
        (local $minvalues v128)
        (local $minindices v128)
        (local $mask v128)
        (local $i i32)
        (local $minscalar i32)
        (local $result i32)
        (local $laneval i32)

        ;; indices[k] is the index of the current vector's k-th lane in the
        ;; input array.
        (local.set $indices (v128.const i32x4 0 1 2 3))

        ;; init minvalues with the first 4 i32 values in the array, and
        ;; minindices with their indices.
        (local.set $minvalues (v128.load (local.get $start)))
        (local.set $minindices (v128.const i32x4 0 1 2 3))
        
        ;; for (i = 4; i < count; i += 4)
        ;; i is the index of i32s in the array
        (local.set $i (i32.const 4))
        (loop $minloop (block $breakminloop
            (br_if $breakminloop (i32.ge_s (local.get $i) (local.get $count)))

            ;; Advance indices
            (local.set $indices
                (i32x4.add (local.get $indices) (v128.const i32x4 4 4 4 4)))

            ;; Load the next 4 i32 values into v
            (local.set $v
                (v128.load
                    (i32.add
                        (local.get $start)
                        (i32.mul (i32.const 4) (local.get $i)))))
            
            ;; Compare v with the current minvalues; the result is a mask
            ;; that specifies where to replace minvalues with v.
            (local.set $mask (i32x4.lt_s (local.get $minvalues) (local.get $v)))

            ;; update minvalues and minindices based on the mask
            (local.set $minvalues
                (v128.bitselect
                    (local.get $minvalues)
                    (local.get $v)
                    (local.get $mask)))
            (local.set $minindices
                (v128.bitselect
                    (local.get $minindices)
                    (local.get $indices)
                    (local.get $mask)))

            (local.set $i (i32.add (local.get $i) (i32.const 4)))
            br $minloop
        ))

        ;; Scalar reduction of the final vector.
        ;;
        ;; For each lane 0..3:
        ;;   minscalar <- min(minscalar, minvalues[lane])
        ;;   result <- index of minscalar, if minscalar < minvalues[lane]
        ;;
        ;; TODO: this is unrolled b/c the argument of extract_lane is
        ;; an immediate.
        (local.set $minscalar (i32x4.extract_lane 0 (local.get $minvalues)))
        (local.set $result (i32x4.extract_lane 0 (local.get $minindices)))

        (local.set $laneval (i32x4.extract_lane 1 (local.get $minvalues)))
        (local.set $minscalar
            (select (local.get $minscalar)
                    (local.get $laneval)
                    (i32.lt_s (local.get $minscalar) (local.get $laneval))))
        (local.set $result
            (select (local.get $result)
                    (i32x4.extract_lane 1 (local.get $minindices))
                    (i32.lt_s (local.get $minscalar) (local.get $laneval))))

        (local.set $laneval (i32x4.extract_lane 2 (local.get $minvalues)))
        (local.set $minscalar
            (select (local.get $minscalar)
                    (local.get $laneval)
                    (i32.lt_s (local.get $minscalar) (local.get $laneval))))
        (local.set $result
            (select (local.get $result)
                    (i32x4.extract_lane 2 (local.get $minindices))
                    (i32.lt_s (local.get $minscalar) (local.get $laneval))))

        (local.set $laneval (i32x4.extract_lane 3 (local.get $minvalues)))
        (local.set $minscalar
            (select (local.get $minscalar)
                    (local.get $laneval)
                    (i32.lt_s (local.get $minscalar) (local.get $laneval))))
        (local.set $result
            (select (local.get $result)
                    (i32x4.extract_lane 3 (local.get $minindices))
                    (i32.lt_s (local.get $minscalar) (local.get $laneval))))

        (local.get $result)
    )

    ;; i32min returns min(a, b)
    (func $i32min (export "i32min") (param $a i32) (param $b i32) (result i32)
        (select 
            (local.get $a)
            (local.get $b)
            (i32.lt_s (local.get $a) (local.get $b)))
    )

    (func $vlog (param $a v128)
        (call $log_4xi32
            (i32x4.extract_lane 0 (local.get $a))
            (i32x4.extract_lane 1 (local.get $a))
            (i32x4.extract_lane 2 (local.get $a))
            (i32x4.extract_lane 3 (local.get $a)))
    )
)   
