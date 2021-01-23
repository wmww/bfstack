# How to run Brainfuck code
You have a few options

## BFStack Engine
To aid with development, BFStack includes a Python3 Brainfuck interpreter in the `engine/` subdirectory. The simplest way to run a program is `./engine/main.py framework/framework.bf`. BFStack programs can be run in any compatible Brainfuck environment, but our engine has some extra features. Notably, it optionally implements assertion checking and property tests. It has no external dependencies except Python3. See [engine/readme.md](engine/readme.md) for more information.

## Compatibility
The core framework should work in any standard brainfuck environment. It does not require values >255 and should never overflow. Subroutines in the standard library may overflow, but should not make any assumptions about cell size. Standard library functions that deal with input should accept 0, -1 or an unchanged cell as EOF. Of course the user of the framework may make whatever assumptions about the environment they wish.

## Additional tools
- [bfc](https://github.com/Wilfred/bfc): an optimizing compiler written in Rust that uses LLVM
- [BrainfuckIDE](https://github.com/wmww/BrainfuckIDE): my own graphical IDE/debugger, great for learning
