# BFStack
*A framework for writing Brainfuck programs with a call stack*

## What is BFStack?
[Boilerplate](bfstack.bf) and a set of rules (this document) for writing programs that will run in a standard Brainfuck environment. Unlike traditional Brainfuck programs, BFStack code is broken up into subroutines. This allows for abstractions, modularity and testability. Subroutines can even call themselves recursively.

## But all that is impossible in Brainfuck
Shut up. I'm clever.

## In this document…
TODO: outline the architecture of the framework, and document how to build a working program using it.

## Memory Layout
| 0 | Call Stack | 0 | Padding | Data Stack | Subroutine Memory | Undefined (for now) |
