Demonstrates some "number crunching" in WASM. The code in `vecadd.wat` adds
together many 4D float32 vectors.

Each vector has float32 components x,y,z,w; the layout of a single vector in
memory is:

    Offset | Value
    --------------
       0      x
       4      y
       8      z
      12      w

Vectors are laid out in linear memory back to back, each occupying 16 bytes.
