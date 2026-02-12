#!/usr/bin/env bash
set -e

make
cd assembler
./assembler 1r.bob 1r.out

# mv testbob.out ../emulator/
cd ../emulator

gdb --args ./emulator ../assembler/1r.out
