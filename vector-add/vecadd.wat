;; Vector addition of f32 in memory exported from host.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; Memory buffer with data imported from the host.
    (import "env" "buffer" (memory 80))

    ;; Logging functions imported from the host.
    (import "env" "log_i32" (func $log_i32 (param i32)))
    (import "env" "log_f32" (func $log_f32 (param f32)))

    ;; Add together $count vectors, each a x,y,z,w tuple (32-bit floats). These
    ;; vectors start at offset $start in linear memory. Write the result in
    ;; a x,y,z,w tuple at offset $dest
    (func $add_scalar_inst (export "add_scalar_inst") (param $start i32) (param $count i32) (param $dest i32)
        (local $i i32)
        (local $read_offset i32)
        (local $x f32)
        (local $y f32)
        (local $z f32)
        (local $w f32)

        ;; Initialize destination vector to 0,0,0,0
        (call $store_scalar_element (local.get $dest) (f32.const 0.0) (f32.const 0.0) (f32.const 0.0) (f32.const 0.0))

        (call $log_i32 (local.get $start))
        (call $log_i32 (local.get $count))
        (call $log_i32 (local.get $dest))

        ;; for i = 0; i < count; i++
        (local.set $i (i32.const 0))
        (loop $addloop (block $breakaddloop
            (i32.ge_s (local.get $i) (local.get $count))
            br_if $breakaddloop

            ;; Each x,y,z,w vector occupies 16 bytes in memory, so the read
            ;; offset is start + i*16
            (local.set $read_offset
                (i32.add
                    (local.get $start)
                    (i32.mul (local.get $i) (i32.const 16))))

            ;; Load x,y,z,w from input
            (local.set $x (f32.load (local.get $read_offset)))
            (local.set $y (f32.load (i32.add (local.get $read_offset) (i32.const 4))))
            (local.set $z (f32.load (i32.add (local.get $read_offset) (i32.const 8))))
            (local.set $w (f32.load (i32.add (local.get $read_offset) (i32.const 12))))

            ;; Add each component into the destination component, and write back
            (local.set $x (f32.add (local.get $x) (f32.load (local.get $dest))))
            (local.set $y (f32.add (local.get $y) (f32.load (i32.add (local.get $dest) (i32.const 4)))))
            (local.set $z (f32.add (local.get $z) (f32.load (i32.add (local.get $dest) (i32.const 8)))))
            (local.set $w (f32.add (local.get $w) (f32.load (i32.add (local.get $dest) (i32.const 12)))))
            (call $store_scalar_element (local.get $dest) (local.get $x) (local.get $y) (local.get $z) (local.get $w))

            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            br $addloop
        ))
    )

    ;; Store a single x,y,z,w vector at the given offset in memory.
    (func $store_scalar_element (param $offset i32) (param $x f32) (param $y f32) (param $z f32) (param $w f32)
        (f32.store (local.get $offset) (local.get $x))
        (f32.store (i32.add (local.get $offset) (i32.const 4)) (local.get $y))
        (f32.store (i32.add (local.get $offset) (i32.const 8)) (local.get $z))
        (f32.store (i32.add (local.get $offset) (i32.const 12)) (local.get $w))
    )

    ;; The same functionailty as add_scalar_inst, but uses SIMD instructions
    ;; to work on whole vectors.
    (func $add_vec_inst (export "add_vec_inst") (param $start i32) (param $count i32) (param $dest i32)
        (local $i i32)
        (local $read_offset i32)

        ;; Initialize destination vector to 0,0,0,0
        (v128.store (local.get $dest) (v128.const f32x4 0.0 0.0 0.0 0.0))

        ;; for i = 0; i < count; i++
        (local.set $i (i32.const 0))
        (loop $addloop (block $breakaddloop
            (i32.ge_s (local.get $i) (local.get $count))
            br_if $breakaddloop

            ;; Each x,y,z,w vector occupies 16 bytes in memory, so the read
            ;; offset is start + i*16
            (local.set $read_offset
                (i32.add
                    (local.get $start)
                    (i32.mul (local.get $i) (i32.const 16))))

            (v128.store
                (local.get $dest)
                (f32x4.add
                    (v128.load (local.get $dest))
                    (v128.load (local.get $read_offset))))

            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            br $addloop
        ))
    )
)