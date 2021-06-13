# Framework architecture
This document will help you understand how the framework works. Unfortunately with a language like Brainfuck, understanding the framework is a requirement for effectively using it.

## Terminology
BFStack programs contain the following abstractions:
- `Module`: A collection of up to 255 numbered subroutines. A library generally takes up one module. A program can contain up to 255 modules. Module 1 is reserved for the standard library (std).
- `Subroutine`: Like a function. Can invoke other subroutines or invoke itself recursively. Each place where other subroutine are invoked is called a label.
- `Label`: Named after C goto labels. Subroutines can jump around between labels (this is how loops are written). Labels split up subroutine sections.
- `Word`: A word contains 4 cells for data, and generally takes up 6 cells on the tape. The stack needs to always be aligned to words, and the two padding cells of each word should never be modified by user code (or should at lease be restored before returning or invoking).
- `Invocation ID`: Contains a module, subroutine and label. Each are between 1-255 with 0 having special meaning depending on context. When stored in a word, they are in that order with the right-most cell always 0. Can be thought of like a C function pointer (except it can specify a specific label within the subroutine).

## The big idea
A BFStack program can be thought of as one big switch statement inside a loop. Each iteration starts with a invocation ID (the label that is to be jumped to, the subroutine it's in and the module that subroutine is in). The framework runs exactly one subroutine section, then detects what it requested and sets up the next iteration.

At an implementation level this is achieved by copying the module number, and decrementing it once for each module in the program until it hits one. When that happens, we know the module we're at is the one with the desired subroutine. Inside that module we then copy the subroutine ID and decrement that until it hits one. Same for the label. Once the subroutine section is done the key number is set to zero and no more labels, subroutines or modules are run. The [dispatch](framework/dispatch.bf) and [case](framework/case.bf) source code have more details.

## Subroutine-framework interface
### Entry
When the program enters a subroutine the tape looks like so (the tape is shown using the BFStack [engine's assertion syntax](engine/readme.md). `` ` `` indicates the current cell. `|`s just hint at the word alignment, and are otherwise not significant):
```
= | M S L 0 | 0 1 | `* * * * | 0 0 | ~
```
Where `M` is the module of the subroutine and `S` is the subroutine. `L` is the label. Initially, we are in the first section so label is 1. This label will increase depending on what section we're in. The padding cells (including the `1` to the left of the current cell) should be left in their original state. The `*`s are the arguments to the subroutine (and can be as few or as many words as the subroutine requires).

### Invoking
When the program invokes another subroutine, the tape should look like this:
```
= | M S 1 0 | 0 0 | `* * * * | 0 0 | ~
```
Where `M` `S` are the invocation ID of the subroutine you want to invoke. `L` is zero, because we always start with the first label in a subroutine. The `*`s are the subroutine's arguments, and can be any number of words.

### After invoking
When a subroutine gets control back after calling another subroutine, the tape looks like this:
```
= | 0 0 0 0 | 0 0 | `* * * * | 0 0 | ~
```
This will be offset from the original entry point. The label (originally 1) at the entry point will have been incremented.

### Returning
When a subroutine returns to it's caller, it leaves the tape like this:
```
= | M S L 0 | 0 1 | `* * * * | 0 0 | ~
```
The `*`s are the return value (can be as many words as you want but the caller must expect and consume it). The five values to the left of the current cell should be the original ones the subroutine was invoked with.

### Whenever a subroutine exits (invoking or returning)
You may notice a similarity between how the tape is left to invoke a subroutine and how it is left when the current subroutine is returning. The pattern is this:
```
= | M S L 0 | 0 C | `* * * * | 0 0 | ~
```
`C` is the return code, which tells the framework what to do (see next section). Some of `M`, `S`, and `L` may be zero depending on the return code.

## Return codes
- `0`: Invoke a subroutine. A new subroutine will be invoked and when it completes the next label of the calling subroutine will be invoked.
  - `M` must be set
  - `S` must be set
  - `L` should be zero, and it will be automatically bumped to 1
- `1`: Return to the subroutine that invoked this one. Must be at the original entry point of this subroutine. `M`, `S` and `L` should not have been touched. They will be automatically cleared.
- `2`: Abort. Graceful shutdown of the program. `M`, `S` and `L` do not matter. Generally this is used by invoking std::abort
- `3`: No such module. Indicates M is an invalid module. Will show an error and abort. Generally set automatically, but can be set manually to mark a module as invalid.
- `4`: No such subroutine. Same, but for subroutines.
- `5`: No such label. Same, but for labels.
