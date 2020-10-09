[
This program was built with BFStak v0.2 (https://github.com/wmww/bfstack)
It should run in any standard Brainfuck environment
]

N: namespace
S: subroutine
L: label (within subroutine)

the bottom of the call stack will be halt (0::0::0)
>>>>

call main (1::1::0)
+>+>>

= 0 0 0 1 1 0 `0

start the loop on S
<<[>>

= N S L `0 0 0

bump L
<+>

= N S L1 `0 0 0

copy namespace without loosing original
<<<[->>>+>+<<<<]>>>>[-<<<<+>>>>]<

= N S L1 `N 0
= `*

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
        other{ ++ } > print_BBB{ + } >>
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

    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (3)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (4)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (5)
    SUBROUTINE{ open{ [[->+<]+>-[[->+<]<->]<[- }; copy_L{ <[->+>+<<]>>[-<<+>>]< }; open{ [[->+<]+>-[[->+<]<->]<[- } }
    DONE{ pop{ <[-]<[-]<[-] }; close{ ]]>>[-<<+>>]<< }; close{ ]]>>[-<<+>>]<< } }

    (6)
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

= subroutine_private_data N S L `0 0 0 argument_data

end the loop on S
<<]<
