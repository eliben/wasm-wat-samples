;; Shows how to do sub-32-bit signed arithmetic.
;;
;; WASM only supports i32 and i64 for parameter types and arithmetic; sub-32-bit
;; arithmetic needs to be emulated in i32, along with helper extension instructions.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (import "env" "log_i32" (func $log_i32 (param i32)))

    (func (export "main")
        (call $log_i32 (call $add8 (i32.const -100) (i32.const -29)))
        (call $log_i32 (call $add8 (i32.const 100) (i32.const 50)))
    )

    (func $add8 (param $a i32) (param $b i32) (result i32)
        local.get $a
        local.get $b
        i32.add
        ;; Interpret low 8 bits as signed int8, extend back to i32
        ;; (for unsigned, could use i32.extend16_s)
        i32.extend8_s    
    )
)
