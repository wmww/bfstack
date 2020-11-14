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
