#!/bin/bash
# Detects a fast way to run Brinfuck on your system, and falls back to the build-in engine if none is available
# The binaries for the interpreters/compilers have to be named the expected thing, and be in your PATH

if test $# != 1; then
    echo "should have one argument, instead have $#"
    exit 1
fi

# https://github.com/rdebath/Brainfuck (tritium subdirectory)
TRITIUM=$(which tritium 2>/dev/null)

# https://github.com/Wilfred/bfc
BFC=$(which bfc 2>/dev/null)

if test ! -z "$TRITIUM"; then
    printf "\x1b[32mrunning with tritium...\x1b[0m\n\n"
    "$TRITIUM" -b $1
elif test ! -z "$BFC"; then
    if diff "$1" /tmp/bfc-code.bf >/dev/null && test -f /tmp/bfc-code; then
        printf "\x1b[32mprogram cached\x1b[0m\n"
        cd /tmp
    else
        printf "\x1b[33mcompiling with bfc...\x1b[0m\n"
        cp "$1" /tmp/bfc-code.bf
        cd /tmp
        "$BFC" bfc-code.bf
    fi
    printf "\x1b[32mrunning...\x1b[0m\n"
    ./bfc-code
else
    printf "\n\x1b[33m"
    printf "using built-in engine. "
    printf "if it's too slow, install a faster interpreter/compiler. "
    printf "see run-bf-fast.sh for details"
    printf "\x1b[0m\n\n"
    DIR="$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"
    "$DIR/../engine/main.py" -r $1
fi
