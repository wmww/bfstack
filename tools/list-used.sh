#!/bin/bash
# List all snippet names used in the given files
set -eo pipefail

grep -Po '[/\w]+(?={)' $@ | sort | uniq
