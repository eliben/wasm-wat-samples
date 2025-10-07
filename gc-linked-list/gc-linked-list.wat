;;
;; TODO add an int field, then code to walk and sum them all up
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
  (type $Node
      (struct
          (field $val i32)
          (field $next (ref null $Node))))

  (global $globalhead (mut (ref null $Node)) (ref.null $Node))
  (export "globalhead" (global $globalhead))

  (func (export "makelist")
    (local $i i32)
    (loop $loop
      (global.set $globalhead
        (struct.new $Node
          (local.get $i)
          (global.get $globalhead)
        )
      )
      (local.set $i
        (i32.add
          (local.get $i)
          (i32.const 1)
        )
      )
      (br_if $loop
        (i32.le_u
          (local.get $i)
          (i32.const 50)
        )
      )
    )
  )
)
