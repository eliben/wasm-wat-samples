;; Importing memory from the host.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
  (import "console" "log" (func $log (param i32 i32)))

  (import "js" "mem" (memory 1))

  (data (i32.const 0) "Hi")

  (func (export "writeHi")
      (call $log (i32.const 0) (i32.const 2))
  )
)

