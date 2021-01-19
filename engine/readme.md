# BFStack Engine
This is a sub-project of BFStack. It is a Brainfuck interpreter implemented in Python3 that supports features useful for development of the framework itself and programs that use it. BFStack programs should run in any compatible environment (see [root BFStack readme](../readme.md) for details) but this engine has some bonus features over a standard interpreter (notably, the assertion system).

## Characteristics
For now, BFStack Engine only supports 8-bit (0 - 255) cells with standard overflow behavior. It allows an arbitrary number of cells to the right (only constrained by host system memory) and errors if the program attempts to go to the left of the start position. Newlines are ASCII 10.

## Optimizations
Sequences of `+`, `-`, `<` and `>` are collapsed down such that the interpreter only has to add one value to each cell changed (even if a single cell is changed multiple times in the sequence). If a loop contains only those four operations, does not contain a net change to the pointer position and the initial cell is decremented by exactly 1, the loop is unrolled into a constant time operation.

With the `-i` flag, you can see how many emulated Brainfuck operations were run (ie how many operations would have been run on a naive interpreter) and how many operations were actually run. Not all of the "real" operations have the same cost, but they are all constant time.

Optimizations can not be made across assertions if enabled. If assertions are not enabled, they do not effect optimization or runtime performance.

## Tests
All tests are currently integration tests found in the tests directory. `run_engine_tests.py` automatically detects and runs all tests. Tests that end with `_fails` are supposed to fail an assertion or encounter a runtime error (such as going too far left). Since tests are just Brainfuck source files with assertions, they should be portable across implementations (assuming they support the assertion syntax specified below)

## Assertions
To aid with development and testing, BFStack uses a custom assertion syntax defined here. The engine will verify all assertions if the `-a` flag is set. This document is the canonical source for the assertion syntax. Assertions are always on their own line (ASCII 10 at the beginning and end) and may not contain any Brainfuck operations.

### Syntax
Assertions start with a `=`. Whitespace (ASCII 9 and ASCII 32) may come before the `=`. They are composed of a sequence of whitespace-separated value matchers. Exactly one of the value matchers must be proceeded by a backtick (`\``). This marks the current cell. If all matchers match their corresponding data tape cells, the assertion passes. Otherwise, the assertion fails.

The data pointer must stay within the range of the assertion until the next assertion unless it has a `~` at the start and/or end. The `~` is like a matcher in that it is whitespace separated from the `=` and other matchers, but it can't be combined, be the current cell or be anywhere but the start and end. It indicates the data pointer may leave the assertion reange in that direction, at which point no other checks are made until the next assertion. A special assertion containing only `= ~` and no current cell clears the current assertion.

A whitespace-separated `|` can be inserted and has no effect. It can be used for indicating layout and whatnot.

### Test Input
Lines queueing test input have the same syntax as assertions, except that they start with a `$` and don't have a current cell marker. Test input has no effect if the program is being run interactivly (real user input is __not__ checked against it). If not being run interactivly, matching values are generated and queued up. Random values are chosen if the matcher can match more than one value. All input must be consumed before the end of the program or the next test input line.

### Matcher Syntax
Matchers are composable expressions that can either match or not match a number. Whitespace is not allowed within a matcher. Matchers are composed of:
- `0`, `1`, `48`, etc: value literals match only their exact value.
- `A`, `FOO`, `count_4`, etc: variables which can be any sequence of letters, underscores and numbers that start with a letter. If the same name didn't appear in the last assertion they are considered "unbound" and match anything. Otherwise, they are considered "bound" to the value they were before and only match that.
- `*`: wildcard, matches any value.
- `@`*<character>*: matches the ASCII value of the given character. *<character>* may be an escape sequence (see below). All ASCII characters are allowed except Brainfuck operations, backslash and whitespace.
- `!`: inverses the following matcher (only matches if it does not match). Can not be applied to an unbound variable.

#### Escape Sequences
An easy way to refer to special characters including characters reserved for Brainfuck operations.
- `\n`: newline (ASCII 10)
- `\t`: tab (ASCII 9)
- `\s`: space (ASCII 32)
- `\\`: backslash (ASCII 92)
- `\:`: `.` (ASCII 46)
- `\;`: `,` (ASCII 44)
- `\#`: `+` (ASCII 43)
- `\~`: `-` (ASCII 45)
- `\{`: `<` (ASCII 60)
- `\}`: `>` (ASCII 62)
- `\(`: `[` (ASCII 91)
- `\)`: `]` (ASCII 93)

## Property Tests
If the `-p` flag is specified, instead of running the program once and exiting, property tests are run. Each test starts at an assertion, generates random values that match that assertion and runs the program to the next assertion or end of file. Each block of code is tested a number of times.
