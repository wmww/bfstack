[
This program was built with BFStak v0.1 (https://github.com/wmww/bfstack)
It should run in any standard Brainfuck environment with 8-bit unsigned cells
]

S: call ID
D: data in the data stack

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

set the landing pad to 2
++

enter the main loop
>+

[-

main <[-[>
    sub_1 { +  } >>>>>
    sub_2 { ++ } >>>>>
]+>]

sub_1 <[-[>
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    +++++++++
    .
    [-]
]+>]

sub_2 <[-[>
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    .
    [-]
]+>]

sub_3 <[-[>
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    +
    .
    [-]
]+>]

D D D D 1 1 `0 0 0
||
S 0 0 0 0 1 `0 0 0

clear the inhibitor byte (one to the right of the flag for the last stack frame)
<[-]<

D D D D `1 0 0 0 0
||
S 0 0 0 `0 0 0 0 0

If there is no subroutine invoked pop one off the call stack
[
    >
    not implemented so print !
    ++++++++++
    ++++++++++
    ++++++++++
    +++
    .
    [-]

    call sub 3
    +++>>>>
]

S 0 0 0 `0 0 0 0 0

<<<+

D D D D 1 S `1 0 0
||
S 0 0 0 0 S `1 0 0

for each subroutine stack frame that is to be pushed on the call stack:
* change its flag from 0 to 2
* move its call ID from the first to the last byte of the word
note that this does not apply to the left most subroutine as it will be invoked immediately
[
    S `1 0 0

    move the call ID to the right of the word
    <[->>>+<<<]

    D D D D 1 `0 1 0 S
    ||
    S 0 0 0 0 `0 1 0 S

    if not flag
    <[>]>>[
        S 0 0 0 0 0 `1 0 S
        -<<++<<<+>>
        S 1 0 `0 2 0 0 0 S
    ]

    <<
    D D D D 1 `0 1 0 S
    ||
    S `1 0 0 2 0 0 0 S
]

D D D D 1 `0 1 0 S 2|0
>->>>
D D D D 1 0 0 0 S `2|0

run to the end of the subroutine invoking stack frames
[>>>>>]<<<<<

`1|2 0 0 0 S 0

push all subroutines but the one to invoke next to the call stack

while the flag is 2 and this is not the left most subroutine
-[-
    1|2 0 0 0 S `0 0 0 0 S 0

    not implemented so print $
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++
    .
    [-]

    remove the call ID
    >>>>[-]

    1|2 0 0 0 S 0 0 0 0 `0 0

    <<<<<<<<<-

    `0|1 0 0 0 S 0
]

D D D D `0 0 0 0 S 0

++>>>>

D D D D 2 0 0 0 `S 0

walk away from the landing pad far enough for the correct subroutine to trigger
[-[->+<]>]<<<+

D D D D 2 call_id_0s `1

]
