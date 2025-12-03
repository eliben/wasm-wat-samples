;; Shows how to do sub-32-bit signed arithmetic.
;;
;; WASM only supports i32 and i64 for parameter types and arithmetic; sub-32-bit
;; arithmetic needs to be emulated in i32, along with helper extension
;; instructions.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (import "env" "log_i32" (func $log_i32 (param i32)))

    (func (export "main")
        ;; WASM guarantees twos-complement wraparound -- signed overflow behaves
        ;; like modular arithmetic.
        (call $log_i32 (call $add8s (i32.const -100) (i32.const -29)))
        (call $log_i32 (call $add8s (i32.const 100) (i32.const 50)))

        (call $log_i32 (call $add16u (i32.const 65530) (i32.const 10)))
    )

    (func $add8s (param $a i32) (param $b i32) (result i32)
        local.get $a
        local.get $b
        i32.add

        ;; Interpret low 8 bits as signed i8, extend back to i32
        i32.extend8_s    
    )

    (func $add16u (param $a i32) (param $b i32) (result i32)
        local.get $a
        local.get $b
        i32.add

        ;; Mask lower 16 bits: we don't need sign extension for 'u' types.
        i32.const 0xFFFF
        i32.and
    )
)
