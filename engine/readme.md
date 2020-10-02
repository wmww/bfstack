# BFStack Engine
This is a sub-project of BFStack. It's a relatively simple Brainfuck implementation written in Python that supports features useful for for BFStack development. BFStack programs should run in any compatible environment (see main BFStack readme for details) but this implementation has features that aid in development (specifically, the testing framework). The goal is for this project to eventually be replaced by a pure brainfuck implementation.

## Characteristics
For now, BFStack Engine only supports 8-bit (0 - 255) cells with sensible overflow behavior. It allows an arbitrary number of cells to the right (only constrained by host system memory) and errors if the program attempts to go to the left of the start position. Newlines are ASCII 0x0A.

## Optimizations
Sequences of `+`, `-`, `<` and `>` are collapsed down such that the interpreter only has to add one value to each cell changed (even if a single cell is changed multiple times in the sequence). If a loop contains only those four operations, does not contain a net change to the pointer and the initial position is decremented by exactly 1, the loop is unrolled into a constant time operation.

With the `-i` flag, you can see how many emulated brainfuck operations were run (ie how many operations would have been run on a naive interpreter) and how many operations were actually run. Not all of the "real" operations have the same cost, but they are all constant time.

Optimizations can not be made across assertions. If assertions are not enabled, they do not effect optimization or runtime performance.

## Tests
All tests are currently integration tests found in the tests directory. `run_engine_tests.py` automatically detects and runs all tests. Tests that end with `_fails` are supposed to fail an assertion or encounter a runtime error (such as going too far left). Since tests are just Brainfuck source files with assertions, they should be portable across implementations (assuming they support the assertion syntax specified below)

## Assertions
NOTE: most of this is not yet tested or implemented

To aid with development and testing, BFStack uses a custom assertion syntax defined here. The engine will verify all assertions if `-a` is enabled. This document is the canonical source for the assertion syntax. Assertions are always on their own line (ASCII 0x0A at the beginning and end) and may not contain any brainfuck operations.

### Tape assertion syntax
Tape assertions start with a `=`. Whitespace (ASCII 0x09 and ASCII 0x20) may come before the `=`. They are composed of a sequence of whitespace-separated value matchers. Exactly one of the value matchers must be proceeded by a backtick (`\``). This marks the current cell. If all matchers match their corresponding data tape cells, the assertion passes. Otherwise, the assertion fails.

### Output assertion syntax
Output assertions have the same syntax as tape assertions, except that they start with a `$` instead of a `=` and may not contain a backtick. The value matchers must match against characters that have already been printed. The assertion "consumes" the matched characters, and future assertions will not try to match against them.

### Test input syntax
Lines queueing test input have the same syntax as output assertions, except that they start with a `?`. Test input has no effect if the program is being run interactivly (real user input is not checked against them). If not being run interactivly, matching values are generated and queued up. Random values are chosen if the matcher can match more than one value. All input must be consumed before the end of the program or the next test input line.

### Value matcher syntax
Value matchers are composable expressions that can either match or not match a number. Whitespace is only allowed within a matcher if it is inside parentheses. Matchers are composed of:
- `0`, `1`, `48`, etc: value literals match only their exact value.
- `A`, `FOO`, `count_4`, etc: variables which can be any sequence of letters, underscores and numbers that start with a letter. If the same name didn't appear in the last tape assertion they are considered "unbound" and match anything. Otherwise, they are considered "bound" to the value they were before and only match that.
- `*`: wildcard, matches any value.
- `@`*<character>*: matches the ASCII value of the given character. Character may be an escape sequence (see below)
- `!`: inverses the following matcher (only matches if it does not match). Can not be applied to an unbound variable.

#### Escape sequences
An easy way to refer to special characters including characters reserved for brainfuck operations.
- `\`*<2-digit hex code>*: the character refered to by the ASCII hex value. Letter digits must be upper case.
- `\n`: newline (0x0A)
- `\t`: tab (0x09)
- `\s`: space (0x20)
- `\\`: backslash (0x5C)
- `\0`: null (0x00)
- `\:`: `.` (0x2E)
- `\;`: `,` (0x2C)
- `\#`: `+` (0x2B)
- `\~`: `-` (0x2D)
- `\{`: `<` (0x3C)
- `\}`: `>` (0x3E)
- `\(`: `[` (0x5B)
- `\)`: `]` (0x5D)
