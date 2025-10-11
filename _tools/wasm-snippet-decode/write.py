# Writes a minimal, valid wasm binary with a couple of functions.

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

# Emit section with given id and contents.
def section(sec_id: int, payload: bytes) -> bytes:
    return bytes([sec_id]) + uleb(len(payload)) + payload

# ===== Type section (id=1) =====
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
type_section = section(1, type_payload)

# ===== Function section (id=3) =====
# It's a list, encoded with a u32 length followed by the encoding of the
# elements.
func_payload = b"".join([
    uleb(2),  # 2 functions
    uleb(0),  # type index 0
    uleb(1),  # type index 1
])
func_section = section(3, func_payload)

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
export_section = section(7, export_payload)

# ===== Code section (id=10 / 0x0A) =====

# Each function body has a list of locals (length, followed by the appropriate
# number of local decls), and then an "expression" which is a sequence of
# bytes encoding instructions, terminated with 0x0B.
body1 = b"".join([
    uleb(0),                 # local decl count = 0
    bytes([0x20]), uleb(0),  # local.get 0
    bytes([0x41]), uleb(1),  # i32.const 1
    bytes([0x6A]),           # i32.add
    bytes([0x0B]),           # end
])

# insert instructions here to check their decoding by 'wasm-tools print'
body2 = b"".join([
    uleb(0),                # local decl count = 0
    bytes(b"\xFB\x02\x00\x00"),
    bytes([0x0B]),          # end
])
code_payload = b"".join([
    uleb(2),            # 2 function bodies
    uleb(len(body1)),   # body size
    body1,
    uleb(len(body2)),   # body size
    body2,
])
code_section = section(0x0A, code_payload)

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
    print("Running 'wasm-tools parse'")
    subprocess.run(["wasm-tools", "print", out_file], check=True)
except FileNotFoundError:
    print("Note: 'wasm-tools' not found")
except subprocess.CalledProcessError as e:
    print(f"Error running wasm-tools: {e}")
