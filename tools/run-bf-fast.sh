#!/bin/bash
# By default this uses the built-in engine
# If you have a faster brainfuck compiler/interpreter installed, modify this script to use that
set -eo pipefail
DIR="$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"

if test $# != 1; then
    echo "should have one argument, instead have $#"
    exit 1
fi

printf "\n\x1b[33musing built-in engine, modify run-bf-fast.sh if you want something faster\x1b[0m\n\n"
"$DIR/../engine/main.py" -r $1
