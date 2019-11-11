[
This program was built with BFStak v0.1 (https://github.com/wmww/bfstack)
It should run in any standard Brainfuck environment
]

[
S: call ID
D: data in the data stack
`: the current cell
:cell:: the padding between words
]

make some room
>>>>>>>>>

0 0 0 0 :0: 0 0 0 0 :`0:

make 25 stack frames for the call stack
>++++++++++[-<+>]<
[-[->>>>>+<<<<<]+>>>>>]

the last word before the data stack starts has a 1 to detect stack overflows
+>+>>>>

:1: 1 0 0 0 :`0:

set landing pad to 2 and enter the main loop
++>+[-

main <[-[>
    sub_1 { + } >>>>>
    sub_4 { ++++ } >>>>>
    sub_2 { ++ } >>>>>
    sub_3 { +++ } >>>>>
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

sub_4 <[-[>
    sub_3 { +++ } >>>>>
    sub_2 { ++ } >>>>>
    sub_1 { + } >>>>>

]+>]

D D D D :1: 1 `0 0 0
||
S 0 0 0 :0: 1 `0 0 0

clear the inhibitor byte (one to the right of the flag for the last stack frame)
<[-]<

D D D D :`1: 0 0 0 0
||
S 0 0 0 :`0: 0 0 0 0

if there is no subroutine invoked pop one off the call stack
[
    data_stack :1: D D D D :`1: 0 0 0 0

    [<<<<<]

    call_stack :0: 0 0 0 S :`0: 0 0 0 0 :1:

    <[->+<]>>>>>>

    call_stack :0: 0 0 0 0 :S: 0 0 0 0 :`1:

    haul it up to the front of the data stack
    [
        -<<<<<
        [->>>>>+<<<<<]
        +>>>>>>>>>>
    ]

    data_stack :1: D D D D :S: 0 0 0 0 :`0:

    <<<<<
    [->+<]
    +>>>>>

    data_stack :1: D D D D :1: S 0 0 0 :`0:
]

S 0 0 0 :`0: 0 0 0 0

<+

D D D D :1: S 0 0 `1
||
S 0 0 0 :0: S 0 0 `1

[
    S 0 0 `1

    move the call ID to the right of the word
    -<<<[->>>+<<<]

    D D D D :1: `0 0 0 S
    ||
    S 0 0 0 :0: `0 0 0 S

    +<[->-<]+>

    D D D D :1: `0 0 0 S
    ||
    S 0 0 0 :1: `1 0 0 S

    [<<+<]>

    D D D D :1: 0 `0 0 S
    ||
    S 0 0 `1 :1: 1 0 0 S
]

D D D D :1: 0 `0 0 S :1|0:

run to the end of the subroutine invoking stack frames
>>>[>>>>>]<<<<

:1: `0|1 0 0 S :0:

push all subroutines but the one to invoke next to the call stack

while this is not the left most subroutine
[
    :1: 0|1 0 0 S :1: `1 0 0 S :0:

    -<->>>>
    [-<<<<+>>>>]
    <<<<<<<<<

    :1: 0|1 0 0 S :S: 0 0 0 0 :0:

    haul the call ID all the way back to the call stack
    [
        ->>>>>
        [-<<<<<+>>>>>]
        +<<<<<<<<<<
    ]

    call_stack :`0: 0 0 0 0 :S: 0 0 0 0 :1:

    >>>>>
    [-<+>]

    call_stack :0: 0 0 0 S :`0: 0 0 0 0 :1:

    >>>>>

    :`1: 0|1 0 0 0 :1: data_stack

    if we have a stack overflow
    >[
        :1: `1 0 0 0 :1: data_stack

        [-]

        print %%%
        ++++++++++
        ++++++++++
        ++++++++++
        +++++++
        ...

        get into empty space past the data stack to halt
        <[>>>>>]>>>>>
    ]<
    else
    [
        :`1: 0 0 0 0 :1: data_stack

        [>>>>>]

        :1: 0|1 0 0 S :1: 0 0 0 0 :`0:

        <<<<<-

        :1: 0|1 0 0 S :`0: 0 0 0 0 :0:
    ]

    <<<<
]

D D D D :1: `0 0 0 S :0:

<+>>>>

D D D D :2: 0 0 0 `S :0:

if the call ID is not 0 (halt)
[
    walk away from the landing pad far enough for the correct subroutine to trigger
    [-[->+<]>]<<<+<
]>

D D D D :2: call_id_0s `1
]
