[
This program was built with BFStak v0.2 (https://github.com/wmww/bfstack)
It should run in any standard Brainfuck environment
]

N: namespace
S: subroutine
L: label (within subroutine)

the bottom of the call stack will be halt (0::0::0)
>>>

call main (1::1::0)
+>+>>

0 0 0 1 1 1 `0

start the loop on S
<<[>>

N S L `0 0 0

bump L
<+>

copy namespace without loosing original
<<<[->>>+>+<<<<]>>>>[-<<<<+>>>>]<

N S L `N 0

std(1)
NAMESPACE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_S{ <<[->>+>+<<<]>>>[-<<<+>>>]< } }

    main(1)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
        ++++++++++
        ++++++++++
        ++++++++++
        ++++++++++
        +++++++++
        .
        [-]
        std{ + } > print_A{ ++ } >>
        INVOKE{ close{ ]]>>[-<<+>>]<< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
        ++++++++++
        ++++++++++
        ++++++++++
        ++++++++++
        ++++++++++
        .
        [-]
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    deref(2)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }

        A B C D: word currently being processed

        memory is stored in words with four data cells and one padding cell each
        the caller has no way to know its global alignment therefor it may be different than the memory pool alignment
        to help with this the memory pool starts with five cells of 1s called the landing pad
        the leftmost cell of the landing pad is a memory pool aligned padding cell as is the zero just to the right of it
        all the caller aligned padding cells from the origin to the landing pad should be 0
        the caller can store whatever it wants in the non padding cells until close to the landing pad
        there should be five or six words worth of 0s to the left of the landing pad

        leave a 0 to land on and a 1 to start the loop
        >>>>>+

        find the landing pad only accessing the padding between words
        leave behind a trail of 1s to find our way back
        [>>>>>+>>>>>[<<<<<->>>>>[-]]<<<<<]>>>>>+

        1 0000 1 0000 1 0000 1 0000 1 0000 0 ???? `1 ????

        extend the landing pad so that the zero to the left is padding according to caller alignment
        <[-]+ <[-]+ <[-]+ <[-]+

        1 0000 1 0000 1 0000 1 0000 1 0000 0 `1111 1 ????

        wipe the five (caller aligned) padding cells to the left of the landing pad
        <[-] <<<<< [-] <<<<< [-] <<<<< [-]<<<<< [-]
        >>>>> >>>>> >>>>> >>>>> >

        1 0000 0 0000 0 0000 0 0000 0 0000 0 `1111 1 ????

        slide to the end of the landing pad to a mem pool aligned padding cell
        [>]

        0 ???? 1 1111 `0 0000

        TODO: find the word to grab

        1 ???? 1 ???? 1 ???? 1 ???? `1 ABCD 0

        [-] <<<<< [-] <<<<< [-] <<<<< [-] >>>>> >>>>> >>>>>

        1 ???? 0 ???? 0 ???? 0 ???? `0 ABCD 0

        non destructively copy the word into padding cells
        >[ -<+ <<<<< <<<<< <<<<< + >>>>> >>>>> >>>>> > ] <[->+<]>
        >[ -<<+ <<<<< <<<<< + >>>>> >>>>> >> ] <<[->>+<<]>>
        the right two use the right side padding for the transient copy
        >[ ->>+ <<<<< <<<<< + >>>>> >>> ] >>[-<<+>>]<<
        >[ ->+ <<<<< + >>>> ] >[-<+>]<

        1 ???? A ???? B ???? C ???? D ABC`D 0

        4<<<< <<<<< <<<<< <<<<< <<<<<

        `1 ???? A ???? B ???? C ???? D ABCD 0

        move the whole word to the zero a word to the right of the landing pad
        leave the padding as 0s like we found it
        [
            [-]
            >>>>> [-<<<<<+>>>>>]
            >>>>> [-<<<<<+>>>>>]
            >>>>> [-<<<<<+>>>>>]
            >>>>> [-<<<<<+>>>>>]
            <<<<< <<<<< <<<<< <<<<< <<<<<
        ]

        0 0000 0 0000 0 0000 0 ???? 1 1111 `0 ???? A ???? B ???? C ???? D

        move the word over the landing pad (still spread out and still on the mem pool's alignment)
        if you work it out each cell needs to jump 6 to the left
        >>>>> [ - <<<<< <<<<< <<<<< <<<<< <<<<< <<<<< + >>>>> >>>>> >>>>> >>>>> >>>>> >>>>>]
        >>>>> [ - <<<<< <<<<< <<<<< <<<<< <<<<< <<<<< + >>>>> >>>>> >>>>> >>>>> >>>>> >>>>>]
        >>>>> [ - <<<<< <<<<< <<<<< <<<<< <<<<< <<<<< + >>>>> >>>>> >>>>> >>>>> >>>>> >>>>>]
        >>>>> [ - <<<<< <<<<< <<<<< <<<<< <<<<< <<<<< + >>>>> >>>>> >>>>> >>>>> >>>>> >>>>>]
        <<<<< <<<<< <<<<< <<<<< <<<<<

        A 0000 B 0000 C 0000 D ???? `1 1111 0 ???? 0 ???? 0 ???? 0 ???? 0

        align the word to the caller and reset caller alignment cells
        because reasons we have to move between 1 and 5 cells over instead of 0 to 4
        we don't want to clobber the left of the landing pad so we bump it to 2 so it will end up 1
        +[
            0 A 0000 B 0000 C 0000 D ? ? ? ? `1

            - <<<<< <<<<< <<<<< <<<<<

            0 `A 0000 B 0000 C 0000 D ? ? ? ? 0

            [-<+>] >>>>>
            [-<+>] >>>>>
            [-<+>] >>>>>
            [-<+>] >>>>>
            <

            A 0 000B 0 000C 0 000D 0 ? ? ? `? 0
        ] <<<<< <<<<< <<<<< <<<<< <<<<<

        `1 ???? A 0000 B 0000 C 0000 D 0000 0 ????

        haul the data back to the start leaving zeros behind on the padding
        [
            [-]
            >>>>> [-<<<<<+>>>>>]
            >>>>> [-<<<<<+>>>>>]
            >>>>> [-<<<<<+>>>>>]
            >>>>> [-<<<<<+>>>>>]
            <<<<< <<<<< <<<<< <<<<< <<<<<
        ]

        `0 0000 A ???? B ???? C ???? D

        recompress the word
        >>>>> [- 4<<<< + 4>>>>]
        >>>>> [- <<<<< 3<<< + 3>>> >>>>>]
        >>>>> [- <<<<< <<<<< 2<< + 2>> >>>>> >>>>>]
        >>>>> [- <<<<< <<<<< <<<<< 1< + 1> >>>>> >>>>> >>>>>]
        <<<<< <<<<< <<<<< <<<<< <<<<<

        `0 ABCD 0 ???? 0 ???? 0 ???? 0

    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (2)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (2)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (2)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (2)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

NAMESPACE_DONE{ close{ ]]>>[-<<+>>]<< } }

other(2)
NAMESPACE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_S{ <<[->>+>+<<<]>>>[-<<<+>>>]< } }

    print_BBB(1)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
        ++++++++++
        ++++++++++
        ++++++++++
        ++++++++++
        ++++++++++
        ++++++++++
        ++++++
        ...
        [-]
        INVOKE{ close{ ]]>>[-<<+>>]<< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

NAMESPACE_DONE{ close{ ]]>>[-<<+>>]<< } }

subroutine_private_data N S `L 0 0 0 argument_data

end the loop on S
<<]<
