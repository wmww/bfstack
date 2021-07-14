#!/bin/bash
# Wrapper around minify.bf
set -eo pipefail

DIR="$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"

printf "\x1b[34mpaste in your code:\x1b[0m\n\n"

# Black magic from https://stackoverflow.com/a/20913871
IFS= read -d '' -n 1 CODE
while IFS= read -d '' -n 1 -t 0.2 c
do
    CODE+=$c
done

printf "\n\n\x1b[34mminifying...\x1b[0m\n"

echo "$CODE" | "$DIR/run-bf-fast.sh" "$DIR/minify.bf"

echo
