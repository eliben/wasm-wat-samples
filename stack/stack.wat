;; The WASM spec's https://webassembly.github.io/spec/core/exec/instructions.html
;; page explains how instructions interact with the stack.
;;
;; Stack illustrations in comments follow the convention that the top of the
;; stack is on the left, e.g.:
;;
;;    [x y ...]
;;
;; Means x is on top of the stack, then y below it, then other stuff below that.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    ;; sub(a, b) returns a-b
    (func $sub (param $a i32) (param $b i32) (result i32)
        ;; When the function is called, its parameters are automatically mapped
        ;; from the stack to $a and $b

        ;; The sub instruction has two parameters, it's a binop according to
        ;; the WASM spec, working as follows:
        ;;  1. pop c2 from the stack
        ;;  2. pop c1 from the stack
        ;;  3. c = binop(c1, c2)
        ;;  4. push c to stack
        ;;
        ;; So in our case, we have to push $a first, then $b to get the
        ;; stack [b a ...]
        local.get $a
        local.get $b

        ;; After calling sub, the stack willl have [(a-b) ...] on it. We don't
        ;; have to do anything else because this is exactly what's expected
        ;; of a function having a single return value.
        i32.sub
    )

    (func $stack_func_call (export "stack_func_call") (result i32)
        ;; A function expects its parameters on the stack: the first param
        ;; is the "deepest". E.g. to call sub(91, 23), we need the stack:
        ;;
        ;;  [23 91 ...]
        ;;
        ;; Prior to calling $sub. This makes the order of pushes "natural".
        i32.const 91
        i32.const 23
        call $sub
    )
)
