[
This program was built with BFStak v0.1 (https://github.com/wmww/bfstack)
It should run in any standard Brainfuck environment with 8-bit unsigned cells
]

set up initial call stack calling only main (subroutine 1):
A: end of call stack
C: byte size seek stopper
D: word size seek stopper
E: First word of zeros
A B C D ___E___
0 0 0 0 0 0 0 
 > > > > > > >

make 3 words worth of call stack padding
this will allow 125 subroutines to be in the call stack
each word will be a 1 followed by four 0s
+++
[-[->>>>>+<<<<<]+>>>>>]

the last word of padding before the data stack has two 1s followed by three 0s so we can detect stack overflows
+>+>>>>

prep to call main
+>+

[-

main <[-
    sub_2 { >>>++<<< }
>+<]>[>]<

sub_1 <[-
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++
    .
    [-]
    sub_2 { >>>++<<< }
>+<]>[>]<

sub_2 <[-
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    +++++
    .
    [-]
    sub_1 { >>>+<<< }
>+<]>[>]<

<+>->>
[-[->+<]>]<<+

]
