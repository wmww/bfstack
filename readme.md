# BFStack
*A framework for writing Brainfuck programs with a call stack*

__Note that BFStack is still a work-in-progress, but initial examples are functional__

## What is BFStack?
BFStack is a Brainfuck framework. It consists of [boilerplate code](framework/framework.bf) and documentation that make it easier to write Brainfuck by hand. BFStack is __not__ a different language or a transpiler. BFStack programs run in a standard Brainfuck environment.

## How does BFStack help me, a Brainfuck developer
Unlike traditional Brainfuck programs, BFStack code is broken up into subroutines. This allows for abstractions, modularity and testability. Subroutines can even call themselves recursively.

## But all that is impossible in Brainfuck
Shut up. I'm clever.

## Compatibility
The core framework should work in any standard brainfuck environment. It does not require values >255 and should never overflow. Subroutines in the standard library may overflow, but should not make any assumptions about cell size. Standard library functions that deal with input should accept 0, -1 or an unchanged cell as EOF. Of course the user of the framework may make whatever assumptions about the environment they wish.

## Engine
To aid with development, BFStack includes a Python3 Brainfuck interpreter in the `engine/` subdirectory. The simplest way to run a program is `./engine/main.py framework/framework.bf`. BFStack programs can be run in any compatible Brainfuck environment, but our engine has some extra features. Notably, it optionally implements assertion checking and property tests. It has no external dependencies except Python3. See [engine/readme.md](engine/readme.md) for more information.

## License
The framework, engine and engine tests are licensed under the permissive MIT license. The only files not licensed under MIT are those found in `engine/bf`. See those individual files for more information.

## Examples
- [minify](tools/minify.bf): minify brainfuck code

## Concepts
BFStack programs contain the following abstractions:
- `Module`: A collection of up to 255 numbered subroutines. A library generally takes up one module. A program can contain up to 255 modules. Module 1 is reserved for the standard library (std).
- `Subroutine`: Like a function. Can invoke other subroutines or invoke itself recursively. Each place where other subroutine are invoked is called a label.
- `Label`: Named after C goto labels. Subroutines can jump around between labels (this is how loops are written). Labels split up subroutine sections.
- `Word`: A word contains 4 cells for data, and generally takes up 6 cells on the tape. The stack needs to always be alligned to words, and the two padding cells of each word should never be modified by user code.
- `Invocation ID`: Contains a module call, subroutine call and label cell. When stored in a word, they are in that order with the right-most cell always 0. Can be thought of like a C funciton pointer (except it can specify a specific label within the subroutine).

## Framework architecture
A BFStThere are three types of iterationsack program can be thought of as a big switch statement with one branch for each module. Inside each module is a switch containing all the subroutines and in each subroutine is a switch containing each section. At it's core, the framework is a loop that runs one of these subroutine sections per iteration.

### Subroutine-framework Interface
When the program enters a subroutine the tape looks like so (the tape is shown using the BFStack [engine's assertion syntax](engine/readme.md). `` ` `` indicates the current cell. `|`s just hint at the word alignment, and are otherwise not significant):
```
= | M S 1 0 | 0 1 | `* * * * | 0 0 | ...
```
Where `M` is the module of the subroutine and `S` is the subroutine. The `*`s are the arguments to the subroutine (and can be as few or as many words as the subroutine requires). The `1` indicates the label. Initially, we are in the first section so label is 1. This label will increase depending on what section we're in.

When a subroutine gets control back after calling another subroutine, the tape looks like this:
```
= | 0 0 0 0 | 0 0 | `* * * * | 0 0 | ...
```
This will be offset from the original entry point. The label (originally 1) at the entry point will have been incremented.

When a subroutine gives control back to the framework (either to return to it's caller, invoke another subroutine or abort) it leaves the tape like this:
```
= | M S L 0 | 0 C | `* * * * | 0 0 | ...
```
The `*`s are the return value (can be as many words as you want but the caller must expect and consume it). `C` is the return code, which tells the framework what to do (see next section). Some of `M`, `S`, and `L` may be zero depending on the return code.

### Return codes
- `0`: Invoke a subroutine. A new subroutine will be invoked and when it completes the next label of the calling subroutine will be invoked.
  - `M` must be set
  - `S` must be set
  - `L` should be zero, and it will be automatically bumped to 1
- `1`: Return to the subroutine that invoked this one. Must be at the original entry point of this subroutine. `M`, `S` and `L` should not have been touched. They will be automatically cleared.
- `2`: Abort. Graceful shutdown of the program. `M`, `S` and `L` do not matter. Generally this is used by invoking std::abort
- `3`: No such module. Indicates M is an invalid module. Will show an error and abort. Generally set automatically, but can be set manually to mark a module as invalid.
- `4`: No such subroutine. Same, but for subroutines.
- `5`: No such label. Same, but for labels.
