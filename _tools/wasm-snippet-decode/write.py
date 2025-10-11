# Writes a minimal wasm binary with one exported function:
#   (func (export "add1") (param i32) (result i32)
#         local.get 0
#         i32.const 1
#         i32.add)
#
# No imports, memories, or custom sections.

def uleb(n: int) -> bytes:
    """Unsigned LEB128 encode."""
    out = []
    while True:
        b = n & 0x7F
        n >>= 7
        if n:
            out.append(b | 0x80)
        else:
            out.append(b)
            break
    return bytes(out)

def sec(sec_id: int, payload: bytes) -> bytes:
    return bytes([sec_id]) + uleb(len(payload)) + payload

# ===== Type section (id=1) =====
# One function type: (param i32) (result i32)
# func-type = 0x60, i32 = 0x7F
type_payload = b"".join([
    uleb(2),          # two types

    # First type: func with (param i32) (result i32)
    bytes([0x60]),    # func type tag
    uleb(1),          # param count: 1
    bytes([0x7F]),    # param type: i32
    uleb(1),          # result count: 1
    bytes([0x7F]),    # result type: i32

    # Second type: func with no params, no results
    bytes([0x60]),    # func type tag
    uleb(0),          # param count: 0
    uleb(0),          # result count: 0
])
type_section = sec(1, type_payload)

# ===== Function section (id=3) =====
func_payload = b"".join([
    uleb(2),  # 2 functions
    uleb(0),  # type index 0
    uleb(1),  # type index 1
])
func_section = sec(3, func_payload)

# ===== Export section (id=7) =====
# Export function 0 under name "add1"
name = b"add1"
export_payload = b"".join([
    uleb(1),            # vector length: 1 export
    uleb(len(name)),    # name length
    name,               # name bytes
    bytes([0x00]),      # kind: 0x00 = function
    uleb(0),            # function index 0
])
export_section = sec(7, export_payload)

# ===== Code section (id=10 / 0x0A) =====
body1 = b"".join([
    uleb(0),                 # local decl count = 0
    bytes([0x20]), uleb(0),  # local.get 0
    bytes([0x41]), uleb(1),  # i32.const 1
    bytes([0x6A]),           # i32.add
    bytes([0x0B]),           # end
])

body2 = b"".join([
    uleb(0),       # local decl count = 0
    bytes([0x0B]), # end
])
code_payload = b"".join([
    uleb(2),            # 2 function bodies
    uleb(len(body1)),   # body size
    body1,
    uleb(len(body2)),   # body size
    body2,
])
code_section = sec(0x0A, code_payload)

# ===== Assemble module =====
wasm = b"".join([
    b"\x00asm",            # magic
    b"\x01\x00\x00\x00",   # version = 1
    type_section,
    func_section,
    export_section,
    code_section,
])

out_file = "out.wasm"
with open(out_file, "wb") as f:
    f.write(wasm)

print("Wrote out.wasm ({} bytes)".format(len(wasm)))

# If wasm-tools is installed, invoke it with 'print' on the
# emitted file and print results to stdout.
import subprocess
try:
    subprocess.run(["wasm-tools", "print", out_file], check=True)
except FileNotFoundError:
    print("Note: 'wasm-tools' not found")
except subprocess.CalledProcessError as e:
    print(f"Error running wasm-tools: {e}")
