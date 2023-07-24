;; This sample shows how to read a file using WASM/WASI.
;;
;; Reading a file requires sandbox permissions in WASM. By default, WASM
;; module cannot access the file system, and they require special permissions
;; to be granted from the host. The majority of this code deals with obtaining
;; the "pre-set" directory the host mapped for us, so we can open the file
;; and read it.
;;
;; Eli Bendersky [https://eli.thegreenplace.net]
;; This code is in the public domain.
(module
    (import "wasi_snapshot_preview1" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "fd_prestat_get" (func $fd_prestat_get (param i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "fd_prestat_dir_name" (func $fd_prestat_dir_name (param i32 i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "path_open" (func $path_open (param i32 i32 i32 i32 i32 i64 i64 i32 i32) (result i32)))
    (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))

    (memory (export "memory") 1)

    (func $main (export "_start")
        (local $errno i32)

        ;; Call fd_prestat_get to obtain length of dir name at fd=3
        ;; We pass the pointer to $prestat_tag_buf -- the actual length will
        ;; be written to the next word in memory, which is $prestat_dir_name_len
        (local.set $errno
            (call $fd_prestat_get (i32.const 3) (global.get $prestat_tag_buf)))
        (if (i32.ne (local.get $errno) (i32.const 0))
            (then
                (call $println_number (local.get $errno))
                (call $die (i32.const 6900) (i32.const 28))))

        ;; Call fd_prestat_dir_name to obtain dir name at fd=3, saving it to
        ;; $fd_prestat_dir_name
        (local.set $errno
            (call $fd_prestat_dir_name
                (i32.const 3)
                (global.get $prestat_dir_name_buf)
                (i32.load (global.get $prestat_dir_name_len))))
        (if (i32.ne (local.get $errno) (i32.const 0))
            (then
                (call $println_number (local.get $errno))
                (call $die (i32.const 6950) (i32.const 33))))

        ;; Sanity checking of the prestat dir: expect it to start with '/'
        ;; (ASCII 47)
        (i32.or
            (i32.lt_u (i32.load (global.get $prestat_dir_name_len)) (i32.const 1))
            (i32.ne (i32.load8_u (global.get $prestat_dir_name_buf)) (i32.const 47)))
        if
            (call $die (i32.const 7025) (i32.const 49))
        end

        ;; Open the input file using fd=3 as the base directory.
        ;; This assumes the input file is relative to the base directory.
        ;; The result of this call will be the fd for the opened file in
        ;; $path_open_fd_out
        ;;
        ;; Note: the rights flags are minimal -- only allowing fd_read.
        ;; Previously I tried giving "all" rights, but this didn't work in
        ;; node (though it did in other runtimes). The reason for this may
        ;; be that each fd has its maximal inheriting rights (specified in
        ;; the fdstat.fs_rights_inheriting field), and we can't open a file
        ;; with higher rights than its parents' inheriting field allows.
        (local.set $errno
            (call $path_open
                (i32.const 3)           ;; fd=3 as base dir
                (i32.const 0x1)         ;; lookupflags: symlink_follow=1
                (i32.const 7940)        ;; file name in memory
                (i32.const 10)          ;; length of file name
                (i32.const 0x0)         ;; oflags=0
                (i64.const 3)           ;; fd_rights_base: fd_read rights
                (i64.const 3)           ;; fd_rights_inheriting: fd_read rights
                (i32.const 0x0)         ;; fdflags=0
                (global.get $path_open_fd_out)))
        (if (i32.ne (local.get $errno) (i32.const 0))
            (then
                (call $println_number (local.get $errno))
                (call $die (i32.const 7090) (i32.const 37))))

        ;; (call $println_number (i32.load (global.get $path_open_fd_out)))

        ;; Populat iovecs for fd_read; we create a single vector with a
        ;; buffer length of 128
        (i32.store (global.get $read_iovec) (global.get $read_buf))
        (i32.store (i32.add (global.get $read_iovec) (i32.const 4)) (i32.const 128))

        (local.set $errno
            (call $fd_read
                (i32.load (global.get $path_open_fd_out))
                (global.get $read_iovec)
                (i32.const 1)
                (global.get $fdread_ret)))
        (if (i32.ne (local.get $errno) (i32.const 0))
            (then
                (call $die (i32.const 7130) (i32.const 29))))

        ;; Print out how many bytes were actually read
        (call $println_number (i32.load (global.get $fdread_ret)))

        ;; Print "read from file" header
        (call $println (i32.const 7170) (i32.const 17))

        ;; ... now print what was actually read; the read buffer was pointed to
        ;; by the fd_read io vector, and use fd_read's "number of bytes read"
        ;; return value for the length.
        (call $println (global.get $read_buf) (global.get $fdread_ret))
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

    ;;
    ;; Memory mapping and initialization.
    ;;

    (data (i32.const 6900) "error: fd_prestat_get failed")
    (data (i32.const 6950) "error: fd_prestat_dir_name failed")
    (data (i32.const 7025) "error: expect first preopened directory to be '/'")
    (data (i32.const 7090) "error: unable to path_open input file")
    (data (i32.const 7130) "error: fd_read failed")
    (data (i32.const 7170) "Read from file:\n")

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
    (global $path_open_fd_out i32 (i32.const 7952))

    ;; Using some memory for a number-->digit ASCII lookup-table, and then the
    ;; space for writing the result of $itoa.
    (data (i32.const 8000) "0123456789")
    (data (i32.const 8010) "\n")
    (global $itoa_out_buf i32 (i32.const 8020))

    ;; Buffer for fd_read
    (global $read_iovec i32 (i32.const 8100))
    (global $fdread_ret i32 (i32.const 8112))
    (global $read_buf i32 (i32.const 8120))
)
