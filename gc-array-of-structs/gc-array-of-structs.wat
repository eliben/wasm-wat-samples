;; An array of struct references, using WASM GC types.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (type $Point (struct (field (mut f64)) (field (mut f64))))
    (type $PointArr (array (mut (ref null $Point))))

    ;; Creates an array with $n elements, null-initialized.
    (func (export "make") (param $n i32) (result (ref $PointArr))
        (array.new_default $PointArr (local.get $n)))

    ;; Set the x,y values of the point at $arr[$n]. This allocates a new point,
    ;; so the array elemement is replaced.
    (func (export "set") (param $arr (ref $PointArr)) (param $n i32) (param $x f64) (param $y f64)
        (array.set $PointArr
            (local.get $arr) (local.get $n)
            (struct.new $Point (local.get $x) (local.get $y)))
    )

    ;; Returns 1 if the element at $arr[$n] is valid (not null), 0 otherwise.
    (func (export "is_valid") (param $arr (ref $PointArr)) (param $n i32) (result i32)
        (i32.eqz (ref.is_null (array.get $PointArr (local.get $arr) (local.get $n))))
    )

    ;; get the x,y from the point at index $n in $arr.
    ;; if $arr[$n] is null, this will throw an exception.
    (func (export "get_xy") (param $arr (ref $PointArr)) (param $n i32) (result f64) (result f64)
        (local $elem (ref null $Point))
        (local.set $elem (array.get $PointArr (local.get $arr) (local.get $n)))
        
        (struct.get $Point 0 (ref.as_non_null (local.get $elem)))
        (struct.get $Point 1 (ref.as_non_null (local.get $elem)))
    )
)
