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
    uleb(1),          # vector length: 1 type
    bytes([0x60]),    # func type tag
    uleb(1),          # param count: 1
    bytes([0x7F]),    # param type: i32
    uleb(1),          # result count: 1
    bytes([0x7F]),    # result type: i32
])
type_section = sec(1, type_payload)

# ===== Function section (id=3) =====
# One function, whose type index is 0
func_payload = b"".join([
    uleb(1),  # vector length: 1 function
    uleb(0),  # type index 0
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
# One body with no locals; instructions:
#   local.get 0   (0x20 0x00)
#   i32.const 1   (0x41 0x01)
#   i32.add       (0x6A)
#   end           (0x0B)
body = b"".join([
    uleb(0),                 # local decl count = 0
    bytes([0x20]), uleb(0),  # local.get 0
    bytes([0x41]), uleb(1),  # i32.const 1
    bytes([0x6A]),           # i32.add
    bytes([0x0B]),           # end
])
code_payload = b"".join([
    uleb(1),         # vector length: 1 function body
    uleb(len(body)), # body size
    body,
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
