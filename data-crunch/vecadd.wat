(module
    ;; Memory buffer with data imported from the host.
    (import "env" "buffer" (memory 80))

    ;; Logging function imported from the host; will print a single i32.
    (import "env" "log" (func $log (param i32)))

    (func $do_add (export "do_add") (param $start i32) (param $count i32) (param $dest i32)
        (call $log (local.get $start))
    )
)