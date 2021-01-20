# BFStack
*A framework for writing Brainfuck programs with a call stack*

__WIP, framework minimally function, documentation not complete__

## What is BFStack?
[Boilerplate](bfstack.bf) and a set of rules (this document) for writing programs that will run in a standard Brainfuck environment. Unlike traditional Brainfuck programs, BFStack code is broken up into subroutines. This allows for abstractions, modularity and testability. Subroutines can even call themselves recursively.

## But all that is impossible in Brainfuck
Shut up. I'm clever.

## In this document…
TODO: outline the architecture of the framework, and document how to build a working program using it.

## Compatibility
TODO: describe what the expectations are made of the Brainfuck environment

## Engine
To aid with development, BFStack includes a Python3 Brainfuck interpreter in the `engine/` subdirectory. The simplest way to run a program is `./engine/main.py bfstack.bf`. BFStack programs can be run in any compatible Brainfuck environment, but our engine has some extra features. Notably, it optionally implements assertion checking and property tests. It has no external dependencies except Python3. See [engine/readme.md](engine/readme.md) for more information.

## Licese
The framework, engine and engine tests are licensed under the permissive MIT license. The only files not licensed under MIT are those found in `engine/bf`. See those individual files for more information.

## Concepts
BFStack programs contain the following abstractions:
- `Module`: A collection of up to 255 numbered subroutines. A library generally takes up one module. A program can contain up to 255 modules. Module 1 is reserved for the standard library (std).
- `Subroutine`: Like a function. Can invoke other subroutines or invoke itself recursively. Each place where other subroutine are invoked is called a label.
- `Label`: Named after C goto labels. Subroutines can jump around between labels (this is how loops are written). Labels split up subroutine sections.
- `Word`: A word contains 4 cells for data, and generally takes up 6 cells on the tape. The stack needs to always be alligned to words, and the two padding cells of each word should never be modified by user code.
- `Invocation ID`: Contains a module call, subroutine call and label cell. When stored in a word, they are in that order with the right-most cell always 0. Can be thought of like a C funciton pointer (except it can specify a specific label within the subroutine).

## Framework Architecture
At it's core, the framework is a loop that runs subroutine sections. There are three types of iterations:
1. Invoking a new subroutine
2. Returning to the middle of a previous subroutine
3. Halt

### Invoking a New Subroutine
To invoke a new subroutine, the tape should be set up like so:
```
= | M S 0 0 | 0 0 | `* * * * | 0 0 | ...
```
Where M is the module of the subroutine and S is the subroutine. The `*`s are the arguments to the subroutine (and can be as few or as many words as the subroutine requires). When the program enters the subroutine, the tape will look like this:
```
= | M S 1 0 | 1 0 | `* * * * | 0 0 | ...
```
Note that the framework bumps the label to 1 (because we enter at the first section of the subroutine) and sets the 1st padding cell to 1 (to indicate the preceding word is a subroutine on the call stack). The arguments are not touched and the current position is restored.

### Returning to a Previous Subroutine
When returning, the call stack should look like this:
```
= | M S L 0 | 1 0 | `* * * * | 0 0 | ...
```
Note that this is exactly how the tape was when the subroutine started. The pointer must be in the same place. The `*`s now represent the returned value. It can be as many words as you like, but the call must expect it and clean it up. Control is then passed back to the next section of the caller and the tape looks like so:
```
= | 0 0 0 0 | 0 0 | `* * * * | 0 0 | ...
```

### Halt
To halt, leaave the tape like this (this should probably be done by a std subroutine):
```
= | 0 0 0 0 | 1 0 | `* * * * | 0 0 | ...
```
