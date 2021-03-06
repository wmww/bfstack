[
This program was built with BFStak v0.3 (https://github.com/wmww/bfstack)
It should run in any standard Brainfuck environment
]

M: module
S: subroutine
L: label (within subroutine)

= `0 ~

make plenty of space at the bottom of the stack
++++++++++[[>>>+<<<-]>>>-]

set the last stack frame to be a call to std(1)::abort(1)
note that the label is left at zero as the framework will bump that when needed
+>+>>>>+

= 0 0 | 1 1 0 0 | 0 `1 | 0 0 0 0 | 0 0

call main (2:1) and specify label 1
>++>+>+>>>+

= 0 1 | 2 1 1 0 | 0 `1

start the main loop
[

= M S L 0 | 0 `*
= ~
= M S L 0 | 0 `1

[-]
non destructively copy M
<<<<<[>>>+>+<<<<-]>>>[<<<+>>>-]>

= M S L 0 | `M 0

std(1)
case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    = M S L 0 | `0 0
    copy_S{ <<<[>>+>+<<<-]>>[<<+>>-]> }

    abort(1)
    = M S L 0 | `S 0
    case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        = M S L 0 | `0 0
        copy_L{ <<[>+>+<<-]>[<+>-]> }
        = M S L 0 | `L 0
        case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
            = M S L 0 | `0 0 | * * * *
            sub_init{ >+> }
            = M S L 0 | 0 1 | `* * * *
            set the abort code
            <+>
            = M S L 0 | 0 2 | `*
            sub_finish{ << }
            = M S L 0 | `0 2 |
        case_end{ ]]<[>+<-]> }
        = M S L 0 | `* *

        if there's still a value the throw "no such label" (return code 5)
        end_sub{ [>[-]+++++<[-]] }
        = M S L 0 | `0 C

    case_end{ ]]<[>+<-]> }
    = M S L 0 | `* *

    if there's still a value the throw "no such subroutine" (return code 4)
    end_mod{ [>[-]++++<[-]] }
    = M S L 0 | `0 C
case_end{ ]]<[>+<-]> }
= M S L 0 | `* *

no great way to express that either the switch value is zero or the return code is zero
= ~

case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    = M S L 0 | `0 0
    copy_S{ <<<[>>+>+<<<-]>>[<<+>>-]> }
    = M S L 0 | `S 0
    case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        = M S L 0 | `0 0
        copy_L{ <<[>+>+<<-]>[<+>-]> }
        = M S L 0 | `L 0
        case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
            = M S L 0 | `0 0 | 0 0 0 0
            sub_init{ >+> }

            = M S L 0 | 0 1 | `0 0 0 0
            [-][ print "a" ]
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            +++++++.
            [-]
            = M S L 0 | 0 1 | `0 0 0 0 | 0 0 | 0

            invoke 2::2
            ++>++>+>>>>
            = 2 2 1 0 | 0 0 | `0
            invoke {
                <<
                case_end{ ]]<[>+<-]> }
                case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
                = ~
                <<<<[[-]>]>>>
            }
            = 0 0 0 0 | 0 0 | `0

            <<<<<<
            = M S L 0 | 0 1 | `0

            sub_finish{ << }
            = M S L 0 | `0 1 |
        case_end{ ]]<[>+<-]> }
        = M S L 0 | `* *

        if there's still a value the throw "no such label" (return code 5)
        end_sub{ [>[-]+++++<[-]] }
        = M S L 0 | `0 C

    case_end{ ]]<[>+<-]> }
    = M S L 0 | `* *
    case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        = ~
        = M S L 0 | `0 0
        copy_L{ <<[>+>+<<-]>[<+>-]> }
        = M S L 0 | `L 0
        case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
            = M S L 0 | `0 0 | 0 0 0 0
            sub_init{ >+> }

            = M S L 0 | 0 1 | `0 0 0 0
            [-][ print "b" ]
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++++
            ++++++++.
            [-]
            = M S L 0 | 0 1 | `0 0 0 0 | 0 0 | 0

            sub_finish{ << }
            = M S L 0 | `0 1 |
        case_end{ ]]<[>+<-]> }
        = M S L 0 | `* *

        if there's still a value the throw "no such label" (return code 5)
        end_sub{ [>[-]+++++<[-]] }
        = M S L 0 | `0 C

    case_end{ ]]<[>+<-]> }
    = M S L 0 | `* *

    if there's still a value the throw "no such subroutine" (return code 4)
    end_mod{ [>[-]++++<[-]] }
    = M S L 0 | `0 C

case_end{ ]]<[>+<-]> }
= M S L 0 | `* *

if there's still a value the throw "no such module" (return code 3)
[>[-]+++<[-]]
= M S L 0 | `0 C

switch on C plus 1 (because switches don't handle 0)
>[<+>-]<
= M S L 0 | `C 0
+

case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    return code is 0 so invoke a subroutine
    TODO: set the namespace subroutine and/or label to default values if they are null
    = M S L 0 | `0 0
    >+<
    = M S L 0 | `0 1
case_end{ ]]<[>+<-]> }
case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    return code is 1 so return

    = M S L 0 | `0 0
    >+<+
    =  0 * | M S L 0 | `1 1

    find the calling subroutine
    [
        =  0 * | * * * * | `1 *
        -<<<<<<+>
        = 1 `A | * * * * | 0 *
        [[-]<->]
        = !A `0 | * * * * | 0 *
        = ~
        <
    ]
    =  M S L_prev 0 | `0 0 | * * * * | 0 *

    add marker back and bump L
    >+<<<+
    = 0 * | * * * * | 0 * | M S `L 0 | 0 1

    copy M
    <<[<<+<<<<<<+>>>>>>>>-]<<[>>+<<-]
    = M * | * * * * | `0 * | M S L 0 | 0 1
    copy S
    >>>[>>+<<<<<+>>>-]>>[<<+>>-]
    = M * | * * * * | S * | M S L `0 | 0 1
    copy L
    <[>+>+<<-]>[<+>-]
    = M * | * * * * | S * | M S L `0 | L 1

    setting to 2 makes the minus at the beginning of the loop not wipe out the marker
    >>+
    = M * | * * * * | S * | M S L 0 | L `2

    haul everything back to the call site
    [
        = M * | * * * * | S * | * * * * | L `* | * * * * | 0 A
        ->>>>>+
        = M * | * * * * | S * | * * * * | L * | * * * * | `1 A
        >[[-]<->]<[>+<-]
        = M * | * * * * | S * | * * * * | L * | * * * * | `0 !A

        could move all three invocation ID components in a fun little loop but that wouldn't get
        optimized as well as the unrolled version
        <<<<<<[>>>>>>+<<<<<<-]
        <<<<<<[>>>>>>+<<<<<<-]
        <<<<<<[>>>>>>+<<<<<<-]
        >>>>>> >>>>>> >>>>>> >
        = 0 * | * * * * | M * | * * * * | S * | * * * * | L `!A
    ]
    = M * | * * * * | S * | * * * * | L `0

    add marker back and clear out the previous invocation ID
    +<<[-]<[-]<[-]<[-]
    = M * | * * * * | S * | `0 0 0 0 | L 1

    assemble the invocation ID
    >>>>  [<<+>>-]
    <<<<<<[>>>+<<<-]
    <<<<<<[>>>>>>>>+<<<<<<<<-]
    >>>>>>>>>>>>
    = 0 * | * * * * | 0 * | M S L 0 | `0 1
case_end{ ]]<[>+<-]> }
case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    return code is 2 so abort
    [-][ print "\nDONE\n" ]
    ++++++++++
    .
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++.
    ++++++++++
    +.
    -.
    ---------.
    ----------
    ----------
    ----------
    ----------
    ----------
    ---------.
    [-]
    this will then abort
case_end{ ]]<[>+<-]> }
case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    return code is 3 so no such module
    [-][ print "ERR_BAD_MOD" ]
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    +++++++++.
    ++++++++++
    +++.
    .
    ++++++++++
    +++.
    ----------
    ----------
    ---------.
    -.
    +++.
    ++++++++++
    ++++++++++
    +++++++.
    ----------
    --------.
    ++.
    ----------
    -.
    ----------
    ----------
    ----------
    ----------
    ----------
    --------.
    [-]
case_end{ ]]<[>+<-]> }
case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    return code is 4 so no such subroutine
    [-][ print "ERR_BAD_SUB\n" ]
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    +++++++++.
    ++++++++++
    +++.
    .
    ++++++++++
    +++.
    ----------
    ----------
    ---------.
    -.
    +++.
    ++++++++++
    ++++++++++
    +++++++.
    ----------
    --.
    ++.
    ----------
    ---------.
    ----------
    ----------
    ----------
    ----------
    ----------
    ------.
    [-]
case_end{ ]]<[>+<-]> }
case_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    return code is 5 so no such label
    [-][ print "ERR_BAD_LABEL\n" ]
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    +++++++++.
    ++++++++++
    +++.
    .
    ++++++++++
    +++.
    ----------
    ----------
    ---------.
    -.
    +++.
    ++++++++++
    ++++++++++
    +++++++.
    ----------
    ---------.
    ----------
    -.
    +.
    +++.
    +++++++.
    ----------
    ----------
    ----------
    ----------
    ----------
    ----------
    ------.
    [-]
case_end{ ]]<[>+<-]> }
[
    = `C_sub_5 0
    >
    [-][ print "ERR_BAD_CODE_#\n" ]
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    +++++++++.
    ++++++++++
    +++.
    .
    ++++++++++
    +++.
    ----------
    ----------
    ---------.
    -.
    +++.
    ++++++++++
    ++++++++++
    +++++++.
    ----------
    ----------
    --------.
    ++++++++++
    ++.
    ----------
    -.
    +.
    ++++++++++
    ++++++++++
    ++++++.
    ----------
    ----------
    ----------
    ----------
    -------
    now it's at 48
    print number plus five (for the five codes we've already checked)
    <[>+<-]>+++++
    .
    ----------
    ----------
    ----------
    --------.
    [-]<[-]
    = `0 0
]

= M S L 0 | `0 *
>
]
