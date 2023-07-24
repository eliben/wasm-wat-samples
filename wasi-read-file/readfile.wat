;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "fd_prestat_get" (func $fd_prestat_get (param i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "fd_prestat_dir_name" (func $fd_prestat_dir_name (param i32 i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "path_open" (func $path_open (param i32 i32 i32 i32 i32 i32 i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))

    (memory (export "memory") 1)

    (func $main (export "_start")
        (local $fdnum i32)
        (call $println_number (i32.const 77))
        (call $println_number (call $fd_prestat_get (i32.const 3) (global.get $prestat_tag_buf)))

        ;; TODO: need some sort of "error abort" functionality here

        ;; the tag should be 0, and the length of the preopen dir is at the next word
        (call $println_number (i32.load (global.get $prestat_tag_buf)))
        (call $println_number (i32.load (global.get $prestat_dir_name_len)))

        (call $fd_prestat_dir_name
            (i32.const 3)
            (global.get $prestat_dir_name_buf)
            (i32.load (global.get $prestat_dir_name_len)))
        drop

        (call $println (global.get $prestat_dir_name_buf) (i32.load (global.get $prestat_dir_name_len)))

        ;; Sanity checking of the prestat dir: expect it to be '.' (ASCII 46)
        (i32.or 
            (i32.ne (i32.load (global.get $prestat_dir_name_len)) (i32.const 1))
            (i32.ne (i32.load8_u (global.get $prestat_dir_name_buf)) (i32.const 46)))
        if
            (call $die (i32.const 7025) (i32.const 49))
        end

        ;; TODO call path_open here, starting with fd 3 which is the right dir
        

        ;; (call $die (i32.const 7820) (i32.const 5))
    )

    ;; println prints a string to stdout using WASI, adding a newline.
    ;; It takes the string's address and length as parameters.
    (func $println (param $strptr i32) (param $len i32)
        ;; Print the string pointed to by $strptr first.
        ;;   fd=1
        ;;   data vector with the pointer and length
        (i32.store (global.get $datavec_addr) (local.get $strptr))
        (i32.store (global.get $datavec_len) (local.get $len))
        (call $fd_write
            (i32.const 1)
            (global.get $datavec_addr)
            (i32.const 1)
            (global.get $fdwrite_ret)
        )
        drop

        ;; Print out a newline.
        (i32.store (global.get $datavec_addr) (i32.const 8010))
        (i32.store (global.get $datavec_len) (i32.const 1))
        (call $fd_write
            (i32.const 1)
            (global.get $datavec_addr)
            (i32.const 1)
            (global.get $fdwrite_ret)
        )
        drop
    )

    ;; Prints a message (address and len parameters) and exits the process
    ;; with return code 1.
    (func $die (param $strptr i32) (param $len i32)
        (call $println (local.get $strptr) (local.get $len))
        (call $proc_exit (i32.const 1))
    )

    ;; println_number prints a number as a string to stdout, adding a newline.
    ;; It takes the number as parameter.
    (func $println_number (param $num i32)
        (local $numtmp i32)
        (local $numlen i32)
        (local $writeidx i32)
        (local $digit i32)
        (local $dchar i32)

        ;; Count the number of characters in the output, save it in $numlen.
        (i32.lt_s (local.get $num) (i32.const 10))
        if
            (local.set $numlen (i32.const 1))
        else
            (local.set $numlen (i32.const 0))
            (local.set $numtmp (local.get $num))
            (loop $countloop (block $breakcountloop
                (i32.eqz (local.get $numtmp))
                br_if $breakcountloop

                (local.set $numtmp (i32.div_u (local.get $numtmp) (i32.const 10)))
                (local.set $numlen (i32.add (local.get $numlen) (i32.const 1)))
                br $countloop
            ))
        end

        ;; Now that we know the length of the output, we will start populating
        ;; digits into the buffer. E.g. suppose $numlen is 4:
        ;;
        ;;                     _  _  _  _
        ;;
        ;;                     ^        ^
        ;;  $itoa_out_buf -----|        |---- $writeidx
        ;;  
        ;;
        ;; $writeidx starts by pointing to $itoa_out_buf+3 and decrements until
        ;; all the digits are populated.
        (local.set $writeidx 
            (i32.sub 
                (i32.add (global.get $itoa_out_buf) (local.get $numlen))
                (i32.const 1)))

        (loop $writeloop (block $breakwriteloop
            ;; digit <- $num % 10
            (local.set $digit (i32.rem_u (local.get $num) (i32.const 10)))
            ;; set the char value from the lookup table of digit chars
            (local.set $dchar (i32.load8_u offset=8000 (local.get $digit)))
            
            ;; mem[writeidx] <- dchar
            (i32.store8 (local.get $writeidx) (local.get $dchar))

            ;; num <- num / 10
            (local.set $num (i32.div_u (local.get $num) (i32.const 10)))

            ;; If after writing a number we see we wrote to the first index in
            ;; the output buffer, we're done.
            (i32.eq (local.get $writeidx) (global.get $itoa_out_buf))
            br_if $breakwriteloop

            (local.set $writeidx (i32.sub (local.get $writeidx) (i32.const 1)))
            br $writeloop
        ))

        (call $println
            (global.get $itoa_out_buf)
            (local.get $numlen))
    )

    ;; Strings we print out
    (data (i32.const 7000) "hello from wat!")
    (data (i32.const 7020) "error")
    (data (i32.const 7025) "error: expect first preopened directory to be '.'")

    ;; These slots are used as parameters for fd_write, and its return value.
    (global $datavec_addr i32 (i32.const 7900))
    (global $datavec_len i32 (i32.const 7904))
    (global $fdwrite_ret i32 (i32.const 7908))

    ;; For prestat calls
    (global $prestat_tag_buf i32 (i32.const 7920))
    (global $prestat_dir_name_len i32 (i32.const 7924))
    (global $prestat_dir_name_buf i32 (i32.const 7936))

    ;; File name
    (data (i32.const 7940) "sample.txt")

    ;; Output buf for path_open to write fd into
    (global $path_open_fd_out i32 (i32.const 7950))

    ;; Using some memory for a number-->digit ASCII lookup-table, and then the
    ;; space for writing the result of $itoa.
    (data (i32.const 8000) "0123456789")
    (data (i32.const 8010) "\n")
    (global $itoa_out_buf i32 (i32.const 8020))
)
