# Words
In bfstack, a word is a 4-cell value. There is typically 2 cells of padding between each word. Depending on context, words can hold different types of values as described here. Each type has a collection of subroutines that operate on it.

## A note on cell size
bfstack is only developed for and tested in brainfuck environments with cells that range from 0-255 and which safely and predictably roll over. Miliage may vary in other environments.

## Integers
Integers are stored as base 256 big-endian (the same order as is commonly used to write numbers). This means the word `0 1 8 45` represents (1 * 65536) + (8 * 256) + 45 or 67629.

Integers may be signed or not. Signed integers use 2's complement. This means -1 is represented as `255 255 255 255`. -2 as `255 255 255 254`, etc. This has the nice property that addition and multiplication work the same for both signed and unsigned words.

# Floating point numbers
Floats fit in one word. The three left-most cells comprise the mantissa (number), and the right-most cell is the exponent. Both use 2's complement. A mantissa of 0 indicates the left-most cell is the 1's place and the other two are the 1/256ths and 1/65536ths respectivly. +2 means the right-most mantissa cell is the 1's place. A negative exponent (>=128) indicates the decimal point has moved in the other direction.
