#!/bin/bash
# Wrapper around minify.bf
set -eo pipefail

DIR="$(realpath "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )")"

echo "paste in your code:"
echo

# Black magic from https://stackoverflow.com/a/20913871
IFS= read -d '' -n 1 CODE
while IFS= read -d '' -n 1 -t 0.2 c
do
    CODE+=$c
done

echo
echo
echo "minifying..."
echo

echo "$CODE" | "$DIR/run-bf-fast.sh" "$DIR/minify.bf"

echo
