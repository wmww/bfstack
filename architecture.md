# Framework architecture
This document will help you understand how the framework works. Unfortanitly with a language like Brainfuck this is probably a requirement for effectivly writing programs in it.

## terminology
BFStack programs contain the following abstractions:
- `Module`: A collection of up to 255 numbered subroutines. A library generally takes up one module. A program can contain up to 255 modules. Module 1 is reserved for the standard library (std).
- `Subroutine`: Like a function. Can invoke other subroutines or invoke itself recursively. Each place where other subroutine are invoked is called a label.
- `Label`: Named after C goto labels. Subroutines can jump around between labels (this is how loops are written). Labels split up subroutine sections.
- `Word`: A word contains 4 cells for data, and generally takes up 6 cells on the tape. The stack needs to always be alligned to words, and the two padding cells of each word should never be modified by user code (or should at lease be restored before returning or invoking).
- `Invocation ID`: Contains a module, subroutine and label. Each are between 1-255 with 0 having special meaning depending on context. When stored in a word, they are in that order with the right-most cell always 0. Can be thought of like a C funciton pointer (except it can specify a specific label within the subroutine).

## The big idea
A BFStack program can be thought of as one big switch statement inside a loop. Each iteration starts with a invocation ID (the label that is to be jumped to, the subroutine it's in and the module that subroutine is in). The framework runs exactly one subroutine section, then detects what it requested and sets up the next iteration.

At an implementation level this is achieved by copying the module number, and decrementing it once for each module in the program until it hits zero. Whent that happens, we know the module we're at is the one with the desired subroutine. Inside that module we then copy the subroutine ID and decrement that until it hits zero. Same for the label. Once the subroutine section is done the key number is set to zero and no more labels, subroutines or modules are run. The [framework](framework/framework.bf) and [case](framework/case.bf) source code have more details.

### Subroutine-framework interface
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
