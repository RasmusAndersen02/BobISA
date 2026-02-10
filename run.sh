#!/usr/bin/env bash
set -e

cd assembler
make
./assembler testbob.bob testbob.out

# mv testbob.out ../emulator/
cd ../emulator
make

./emulator ../assembler/testbob.out
