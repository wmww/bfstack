# BFStack Engine
This is a sub-project of BFStack. It is a Brainfuck interpreter implemented in Python3 that supports features useful for development of the framework itself and programs that use it. BFStack programs should run in any standard Brainfuck environment, but this engine has some bonus features over a standard interpreter (notably, the assertion and systems).

## Characteristics
For now, BFStack Engine only supports 8-bit (0 - 255) cells with standard overflow behavior. It allows an arbitrary number of cells to the right (only constrained by host system memory) and errors if the program attempts to go to the left of the start position. Newlines are ASCII 10. EOF is 0.

## Tests
All tests are currently integration tests found in the tests directory. `run_engine_tests.py` automatically detects and runs all tests. Tests that end with `_fails` are supposed to fail an assertion or encounter a runtime error (such as going too far left). Since tests are just Brainfuck source files with assertions, they should be portable across implementations (assuming they support the assertion syntax specified below)

## Assertions
To aid in developing and testing Brainfuck programs, we support a custom assertion syntax defined here. The engine verifies all assertions by default. This document is the canonical source for the assertion syntax. Assertions are always on their own line (ASCII 10 at the beginning and end) and may not contain any Brainfuck operations.

### Syntax
Assertions start with a `=`. Whitespace (ASCII 9 and ASCII 32) may come before the `=`. They are composed of a sequence of whitespace-separated value matchers. Exactly one of the value matchers must be proceeded by a backtick (`\``). This marks the current cell. If all matchers match their corresponding data tape cells, the assertion passes. Otherwise, the assertion fails.

The data pointer must stay within the range of the assertion until the next assertion unless it has a `~` at the start and/or end. The `~` is like a matcher in that it is whitespace separated from the `=` and other matchers, but it can't be combined, be the current cell or be anywhere but the start and end. It indicates the data pointer may leave the assertion range in that direction, at which point no other checks are made until the next assertion. A special assertion containing only `= ~` and no current cell clears the current assertion.

A whitespace-separated `|` can be inserted and has no effect. It can be used for indicating layout and whatnot.

### Matcher Syntax
Matchers are composable expressions that can either match or not match a cell value. Whitespace is not allowed within a matcher. Matchers are composed of:
- `0`, `1`, `48`, etc: value literals match only their exact value.
- `A`, `FOO`, `count_4`, etc: variables which can be any sequence of ASCII letters, underscores and numbers. It must not start with a number. If the same name didn't appear in the last assertion it is considered "unbound" and matches anything. Otherwise, it is considered "bound" to the value it was before and only matches that.
- `*`: wildcard, matches any value.
- `!`: inverses the following matcher (only matches if it does not match). Can not be applied to an unbound variable.

## Property Tests
If the `-t` flag is specified, instead of running the program once and exiting, tests are run. Each test starts at an assertion, generates random values that match that assertion and runs the program to the next assertion or end of file. Any requested user input is also randomly generated. Each block of code is tested a number of times.

## Tagged snippets
The bests method of code reuse in BFStack programs is to abstract the common code into a subroutine, but that's not always a practical option. If you want to use the same code in multiple places and make sure it stays in sync, you can use a tagged snippet. Tagged snippets start with a tag, followed by a curly brace block. For example:
```brainfuck
move_and_add_1{ [>+<-]>+< }
```
Tags may contain any characters other than whitespace and brainfuck operations. There may not be a space between the tag and the opening curly brace. If there are multiple snippets in a file with the same tag and snippet checking is enabled, The engine will produce an error if they don't all contain the same code. Only Brainfuck code needs to match, not comments, assertions, etc. Tagged snippets may contain unbalanced Brainfuck loop starts end ends.

Long snippets sometimes have the snippet name after the `}` as well. This is allowed, but not currently checked by the engine.

## Using snippets from other files
Snippets from other files can be used as well. First, the file must be imported in the header block. This is a loop that starts at the very start of the program. Since the initial cell always starts at 0, it is guaranteed not to run and so can safely contain Brainfuck instructions.

To use a file:
```brainfuck
[
use "../some/file.bf"
]

file/snippet{ ... }
```
As always, you have to manually fill in the contents of the snippet, but the engine will tell you if it doesn't match. The prefix is always the file name without the extension.

## Optimizations
Sequences of `+`, `-`, `<` and `>` are collapsed down such that the interpreter only has to add one value to each cell changed (even if a single cell is changed multiple times in the sequence). If a loop contains only those four operations, does not contain a net change to the pointer position and the initial cell is decremented by exactly 1, the loop is unrolled into a constant time operation.

With the `-i` flag, you can see how many emulated Brainfuck operations were run (ie how many operations would have been run on a naive interpreter) and how many operations were actually run. Not all of the "real" operations have the same cost, but they are all constant time. The `-0` flag disables all optimizations.

Optimizations can not be made across assertions if enabled. If assertions are not enabled, they do not effect optimization or runtime performance. Tagged snippets never effect optimization or runtime performance.
