// Auxiliary sample in C that compiles to WASM/WASI.
//
// To run it, assuming wasi-sdk installed at $WSDK:
//
//  $WSDK/bin/clang --sysroot=$WSDK/share/wasi-sysroot open-read.c -o or.wasm
//  wasmtime run --mapdir /::. or.wasm
//
// Eli Bendersky [https://eli.thegreenplace.net]
// This code is in the public domain.
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

#define BUFFER_SIZE 128

int main() {
    char buffer[BUFFER_SIZE];

    int fd = open("sample.txt", O_RDONLY);
    if (fd < 0) {
        perror("Failed to open file");
        return 1;
    }

    ssize_t bytesRead = read(fd, buffer, BUFFER_SIZE - 1);
    if (bytesRead < 0) {
        perror("Failed to read file");
        close(fd);
        return 1;
    }
    // Null terminate the string we've read, so we can printf it.
    buffer[bytesRead] = '\0';

    printf("Read from file:\n%s\n", buffer);
    close(fd);
    return 0;
}
