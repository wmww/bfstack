# BFStack
*A framework for writing Brainfuck programs with a call stack*

__Note that BFStack is still a work-in-progress, but initial examples are functional__

## FAQ
### What is BFStack?
BFStack is a Brainfuck framework. It consists of [boilerplate code](framework/framework.bf) and documentation that make it easier to write Brainfuck by hand. BFStack is __not__ a different language or a transpiler. BFStack programs run, unmodified, in a standard Brainfuck environment.

### How does BFStack help me, a Brainfuck developer?
Unlike traditional Brainfuck programs, BFStack code is broken up into subroutines. This allows for abstractions, modularity and testability. Subroutines can even call themselves recursively.

### But all that is impossible in Brainfuck
Shut up. I'm clever.

## Links
- [minify.bf](tools/minify.bf): minifies Brainfuck code, and is a relatively simple example of a program build with the framework
- [framework.bf](framework/framework.bf): the framework and standard library, with comments and assertions
- [how-to-run.md](how-to-run.md): talks about compatibility and tools to run Brainfuck
- [architecture.md](architecture.md): describes framework architecture
- [engine/readme.md](engine/readme.md): Our own Brainfuck interpreter and testing framework

## License
The framework, engine and engine tests are licensed under the permissive MIT license. The only files not licensed under MIT are those found in `engine/bf`. See those individual files for more information.
