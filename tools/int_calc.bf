[
This program was built with BFStak (https://github.com/wmww/bfstack)
It should run in any standard Brainfuck environment

EOF may be 0, -1 or cell unchanged

use "../framework/bfstack.bf"
use "../framework/string.bf"
use "../framework/int.bf"
use "../framework/word.bf"
use "../framework/case.bf"
]

bfstack/header{
++++++++++[[>>>+<<<-]>>>-]+>+>>>>+>++>+>+>>>+[[-]<<<<<[>>>+>+<<<<-]>>>[<<<+>>>-]
>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<
[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+><+><<]]<[>+<-]>[>[-]+++++<[-]]]]<[
>+<-]>[>[-]++++<[-]]]]<[>+<-]>
}

main_module(2)
bfstack/mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[- <<<[>>+>+<<<-]>>[<<+>>-]> }

main(1)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0

    Read and parse the first number

    read_line( ++>++>+>>>> )
    = M S L 0 | 0 1 | 2 2 1 0 | 0 0 | `0 0 0 0 | 0 0 | 0 0 0 0
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7

    <<<<<<
    parse_int( ++>++++>+>>>> )
    = M S L 0 | 0 1 | 2 4 1 0 | 0 0 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | `N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0

    Read and parse the operation

    >>>>>>
    read_line( ++>++>+>>>> )
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 2 2 1 0 | 0 0 | `0 0 0 0
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | `S0 S1 S2 S3 | 0 0 | ~

    Clear out all but the first cell
    >>>>>>
    string/clear{ [[-]>[-]>[-]>[-]>+>>]<<[[-]<<<<<<]>> }
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | S0 S1 S2 S3 | 0 0 | `0 0 0 0
    <<<[-]<[-]<[-]<
    ----------
    ----------
    ----------
    ----------
    -
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | `S0_minus_41 0 0 0 | 0 0 | 0 0 0 0
    [>+<-]>
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | 0 `S0_minus_41 0 0 | 0 0 | 0 0 0 0
    10 is the subroutine code for report_bad_op{}
    <<<<++++++++++>>>>
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 10 | 0 0 | 0 `S0_minus_41 0 0 | 0 0 | 0 0 0 0
    42: Asterisk
    43: Plus
    44: Comma
    45: Minus
    46: Period
    47: Slash
    start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        Multiply
        <<<<[-]++++++++>>>>
    end{ ]]<[>+<-]> }
    start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        Add
        <<<<[-]++++++>>>>
    end{ ]]<[>+<-]> }
    start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        Comma; ignore
    end{ ]]<[>+<-]> }
    start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        Substract
        <<<<[-]+++++++>>>>
    end{ ]]<[>+<-]> }
    start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        Period; ignore
    end{ ]]<[>+<-]> }
    start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        Divide
        <<<<[-]+++++++++>>>>
    end{ ]]<[>+<-]> }
    [-]
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 op | 0 0 | 0 `0 0 0 | 0 0 | 0 0 0 0
    <<<<[<<< <<<<<< <<<<< + >>>>> >>>>>> >>> -]<<<
    = M S L 0 | 0 1 | 0 op 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | `0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0

    Read and parse the second number

    read_line( ++>++>+>>>> )
    = M S L 0 | 0 1 | 0 op 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 2 2 1 0 | 0 0 | `0 0 0 0
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 op 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | `S0 S1 S2 S3

    <<<<<<
    parse_int( ++>++++>+>>>> )
    = M S L 0 | 0 1 | 0 op 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 2 4 1 0 | 0 0 | `S0 S1 S2 S3
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 op 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | `A0 A1 A2 A3

    <<<<<<[-]>[-]>[-]>>>>
    = M S L 0 | 0 1 | 0 op 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | `A0 A1 A2 A3
    move_left{ [<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<< }
    = M S L 0 | 0 1 | 0 op 0 0 | 0 0 | N0 N1 N2 N3 | 0 0 | `A0 A1 A2 A3 | 0 0 | 0 0 0 0
    <<<<<<

    Set up call
    <<<<<<++>>+>>>>
    = M S L 0 | 0 1 | 2 op 1 0 | 0 0 | `N0 N1 N2 N3 | 0 0 | A0 A1 A2 A3 | 0 0 | 0 0 0 0
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | `N0 N1 N2 N3 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0

    <<<<<<
    format_int( ++>+++++>+>>>> )
    = M S L 0 | 0 1 | 2 5 1 0 | 0 0 | `N0 N1 N2 N3 | 0 0 | 0 0 0 0
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7

    <<<<<<
    print( ++>+++>+>>>> )
    = M S L 0 | 0 1 | 2 3 1 0 | 0 0 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7
    bfstack/invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7

    <<<<<<
    = M S L 0 | 0 1 | `0 0 0 0 | 0 0 | S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

read_line(2)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 ~
    string/read_line{ >>>>+<<<<,----------[++++++++++>[>>>>>>+<<<<],----------]-[+>-]<<<<<<[-<<<<<<]>> }
    = M S L 0 | 0 1 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

print(3)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7 ~
    string/print{
        [[.[>>>>+<<<<-]]>>>>[<<<<+>>>>-]<<<[.[>>>+<<<-]]>>>[<<<+>>>-]<<[.[>>+<<-]]>>[<<+
        >>-]<[.[>+<-]]>[<+>-]+>>]<<[[-]<<<<<<]>>
    }
    = M S L 0 | 0 1 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

parse_int(4)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7 ~
    string/parse_int{
        [>>>>+>>]<<[[-]<<<<[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<
        <<<<-]>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>>[
        >>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>>[>>>>>>+<<<
        <<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<<<<<<<<<<<<<<<<
        <<<<<]>>>>>>>>>>>>>>>>>>>>>>>>>>[<<+<<<<<<<<<+>>>>>>>>>>>-]<<[>>+<<-]<<<<<<<<<<<
        <+>>><+++++++++++[>----<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<+>>>>>>>>>>>>>>[-]>[<+>-
        ]>[<+>-]>[<+>-]<<<<<<<<<<<<<<]]<[>+<-]>[-]>>>>>>>>>>>[[<<<<<<<<<<<<<<<<<<<<<<<<[
        >>>>+>>+<<<<<<-]>>>>[<<<<+>>>>-]<<<[>>>+>>>+<<<<<<-]>>>[<<<+>>>-]<<[>>+>>>>+<<<<
        <<-]>>[<<+>>-]<[>+>>>>>+<<<<<<-]>[<+>-]<<<<>>>>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<
        -]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>
        +<<<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<<<<<<<<<+++++++++[>>>>>>>>>>>>>>[<<+<<<<+>>>>
        >>-]<<[>>+<<-]>>>[<<<+<<<+>>>>>>-]<<<[>>>+<<<-]>>>>[<<<<+<<+>>>>>>-]<<<<[>>>>+<<
        <<-]>>>>>[<<<<<+<+>>>>>>-]<<<<<[>>>>>+<<<<<-]>><<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>
        >>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>++++[<<<<<
        <<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]<+>>+<<[>>-<<[>+<-]]>[<+>-]]<
        <<<[>>>+>>+<<[>>-<<[>+<-]]>[<+>-]<<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[-
        ]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[-]<<<<<<<<<
        <<<<<>>>>-]>>>>>>>>>>>>>>[-]>[-]>[-]>[-]>>><<++++++[>>--------<<-]>>[<<<<<<<<<<<
        <<<[<+<+>>-]<[>+<-]<[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<<<<<>>>[>>>+<<<-]>>>+[<<<+>>>>
        +<-]+>[<[-]>[-]]<[[-]<<<<[>>>>+<<<<-]>>>>+[<<<<+>>>>>+<-]+>[<[-]>[-]]<[[-]<<<<<[
        >>>>>+<<<<<-]>>>>>+[<<<<<+>>>>>>+<-]+>[<[-]>[-]]<[[-]<<<<<<+>>>>>>]]]<<<<<<>>>>>
        >>>]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<<<<<>>>[>>>+>+<<<<-]>>>-[<<<+>>>-]+>[
        <[-]>[-]]<[[-]<<<<[>>>>+>+<<<<<-]>>>>-[<<<<+>>>>-]+>[<[-]>[-]]<[[-]<<<<<[>>>>>+>
        +<<<<<<-]>>>>>-[<<<<<+>>>>>-]+>[<[-]>[-]]<[[-]<<<<<<->>>>>>]]]<<<<<<>>>>>>>>]]<[
        >+<-]>[-]>>>>>>>>>>>>>>>>-][-]>[<+>-]>[<+>-]>[<+>-]<<<]>[-]>[-]>[-]>>>[[<<<<<<+>
        >>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<>>>>>>>>>>>>]
        <<<<<<<<<<<<[<<<<<<]>>>>>>]<<<<<<<<<<<<<<[-]<<<<<<<<<<
    }
    = M S L 0 | 0 1 | `N0 N1 N2 N3
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

format_int(5)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `N0 N1 N2 N3 ~
    string/format_int{
        [>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>>[<<+<<<<+>
        >>>>>-]<<[>>+<<-]<<<<[>+>+<<-]>>[<<+>>-]<<[->+>>+<<[[>+<-]>>[-]<<]>[<+>-]>[<+<<[
        -]>>>[-]]<<<]>[-]>[<<+>>-]<<[[>+<-]>>>>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>
        >>+<<<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<>>>>>>>>>>>>>>>++++[<<<<<<<<<<<<[>>>>>>>>>+
        <<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]>+<<[>>-<<[>+<-]]>[<+>-]<->]<<<<[>>>>>+<<[>>-<<
        [>+<-]]>[<+>-]<-<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[-]<[>+<-]<[>+<-]<[>
        +<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[-]<<<<<<<<<<<<<<<<<<<<]>>>>>>
        >>>>>>+[[-]>>>>>>>>>>>>>>>>>>>>>>>>[>>>>+>>]<<[[-]<[>>>+<<<-]<<<>>>[-]<[>+<-]<[>
        +<-]<[>+<-]<<]>><<<<<<<<<<<<<<<<<<<<<++++++++++<<<<<<<<<>>>>>>>>>>-[<<<<[>>>>[-]
        >>+<<<<<<-]>>>>>>[<<<<<<+>>>>>>-]<<[-[>>+<<-]<<<<<<+>>[-]>[<+>-]>[<+>-]>[<+>-]<<
        <>>>>]>>[<<+>>-]<<]<<<<<<+>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[
        >>>>>>+<<<<<<-]>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<
        <<<-]>>><<<<<<<<<<<<<<[>>>>>>>>>>>>>>>>>>>>[-]>[<+>-]>[<+>-]>[<+>-]<<<<<<<<<<<<<
        <<+[[-]>>>>>>>>>>>>>>>+<<<<<<<<<[<<+<<<<+>>>>>>-]<<[>>+<<-]>>>[<<<+<<<+>>>>>>-]<
        <<[>>>+<<<-]>>>>[<<<<+<<+>>>>>>-]<<<<[>>>>+<<<<-]>>>>>[<<<<<+<+>>>>>>-]<<<<<[>>>
        >>+<<<<<-]>><<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>
        >>>-]<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>++++[<<<<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>
        >>>>>[<+>-]<[[-]>+<<[>>-<<[>+<-]]>[<+>-]<->]<<<<[>>>>>+<<[>>-<<[>+<-]]>[<+>-]<-<
        <<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[
        <<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<<<+>>[<<[-]>>[-]]<<]>>>>>>>>>>>>>>>-<<<<<<<<<[<
        <+<<<<+>>>>>>-]<<[>>+<<-]>>>[<<<+<<<+>>>>>>-]<<<[>>>+<<<-]>>>>[<<<<+<<+>>>>>>-]<
        <<<[>>>>+<<<<-]>>>>>[<<<<<+<+>>>>>>-]<<<<<[>>>>>+<<<<<-]>><<<<<<[<<<<<<+>>>>>>-]
        >[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<<<<<<<>>>>>>>>>>>>>>
        >++++[<<<<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]<+>>+<<[>>-<<[>+<-
        ]]>[<+>-]]<<<<[>>>+>>+<<[>>-<<[>+<-]]>[<+>-]<<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]
        <<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[
        -]<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<<<<<<<<<-]>>>
        >>>>>>>>>>>[-]>[-]>[-]>[-]>>>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>
        [<<<<<<+>>>>>>-]<<<<<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<
        <<<+>>>>>>-]<<<<<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+
        >>>>>>-]<<<<<<<<<<<<<<<>>++++++++[>++++++<-]>[>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<
        <<<<<<<<<<<<<<<<<<<<<-]>>>[<<[-]+<<<<+>>>>>>-]>[<<<[-]+<<<+>>>>>>-]>[<<<<[-]+<<+
        >>>>>>-]>[<<<<<[-]+<+>>>>>>-]<<<<<[>>+<<-]>>]>>>>>>>>>>>>>>>>>>>>>>>>[[<<<<<<+>>
        >>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<>>>>>>>>>>+>>]
        <<[[-]<<<<<<]<<<<[[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>
        >>>-]<<<<<<<<<>>>>>>>>>>+>>]<<[[-]<<<<<<]<<<<[[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>
        [<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<>>>>>>>>>>+>>]<<[[-]<<<<<<]<<<<[[<<<<<
        <+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<>>>>>>>>>>
        +>>]<<[[-]<<<<<<]<<<<[[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<
        +>>>>>>-]<<<<<<<<<>>>>>>>>>>+>>]<<[[-]<<<<<<]<<<<<<<<<[[-]>>>>>[>>>>+>>]<<[[-]<[
        >>>+<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<]>>++++++++++++++++++++++++++++++++++++
        +++++++++<<<<<]>>>>>[[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+
        >>>>>>-]<<<<<<<<<>>>>>>>>>>+>>]<<[[-]<<<<<<]<<<<
    }
    = M S L 0 | 0 1 | `S0 S1 S2 S3 | 0 0 | S4 S5 S6 S7
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

add_int(6)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `A0 A1 A2 A3 | 0 0 | B0 B1 B2 B3 ~
    int/add{
        >>>>>>>>>>>>>>>++++[<<<<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]<+>>
        +<<[>>-<<[>+<-]]>[<+>-]]<<<<[>>>+>>+<<[>>-<<[>+<-]]>[<+>-]<<<<-]<<<>>>[-]<[>+<-]
        <[>+<-]<[>+<-]<<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>
        >>>>>-]>>>-]<[-]<<<<<<<<<<<<<<
    }
    = M S L 0 | 0 1 | `X0 X1 X2 X3 | 0 0 | 0 0 0 0
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

sub_int(7)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `A0 A1 A2 A3 | 0 0 | B0 B1 B2 B3 ~
    int/sub{
        >>>>>>>>>>>>>>>++++[<<<<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]>+<<
        [>>-<<[>+<-]]>[<+>-]<->]<<<<[>>>>>+<<[>>-<<[>+<-]]>[<+>-]<-<<<-]<<<>>>[-]<[>+<-]
        <[>+<-]<[>+<-]<<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>
        >>>>>-]>>>-]<[-]<<<<<<<<<<<<<<
    }
    = M S L 0 | 0 1 | `X0 X1 X2 X3 | 0 0 | 0 0 0 0
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

mul_int(8)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `A0 A1 A2 A3 | 0 0 | B0 B1 B2 B3 ~
    int/mul{
        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>++++[->++++<[>->+<<-]>>[<<+>>-]<<<<<<<<<<<<<<<<<<<
        <<<<<<<<<<<<<[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<-
        ]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>[-<<<<<<<<<<<<<<<<<<<<<<<<<[>>>>>>>>>>>>+>>>>>>+
        <<<<<<<<<<<<<<<<<<-]>[>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<-]>[>>>>>>>>>>>>+>>>
        >>>+<<<<<<<<<<<<<<<<<<-]>[>>>>>>>>>>>>+>>>>>>+<<<<<<<<<<<<<<<<<<-]>>>>>>>>>[<<<<
        <<<<<<<<+>>>>>>>>>>>>-]>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>[<<<<<<<<<<<<+>>>>>>>>>>>>-
        ]>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>>>>>>>>[>>+<<<<<<<<<<<<+>>>>>>>>>>-]>>[<<+>>-]<
        <<<<<<<<<<<[>>>>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<-]>>>[-]>[-]>[-]>[<<<<<<<<<+>>>>>>>
        >>-]>>>>>[>+<<<<<<<<<<<<<<+>>>>>>>>>>>>>-]>[<+>-]<<<<<<<<<<<<<<<[>>>>>>+<<<<<<-]
        >[>>>>>>+<<<<<<-]>>>>>>[<[<<<+<+>>>>-]<<<<[>>>>+<<<<-]>[<<+<+>[<->[>+<-]]>[<+>-]
        >-]>>>>-]<[-]<<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>
        >>>>>[<<<+<<<+>>>>>>-]<<<[>>>+<<<-]>>>>[<<<<+<<<+>>>>>>>-]<<<<[>>>>+<<<<-]<<<[<<
        <<<<[-]>[<+>-]>[<+>-]>[<+>-]<<<>>>>>>-]<<<<<<<<<<<<>>>>>>>>>>>>>>>++++[<<<<<<<<<
        <<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]<+>>+<<[>>-<<[>+<-]]>[<+>-]]<<<<[
        >>>+>>+<<[>>-<<[>+<-]]>[<+>-]<<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[-]<[>
        +<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[-]<<<<<<<<<<<<<
        <>>>>>>>>>>>>>>>>>>>]>[-]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]>[<+>-]>[<+>-]>[<+>-
        ]<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[-]>[-]>[-]>[-]
        >>>[-]>[-]>[-]>[-]>>>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+
        >>>>>>-]<<<<<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>
        >>-]<<<<<<<<<
    }
    = M S L 0 | 0 1 | `X0 X1 X2 X3 | 0 0 | 0 0 0 0
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

div_int(9)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `A0 A1 A2 A3 | 0 0 | B0 B1 B2 B3 ~
    int/div_signed{
        >>>>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>>[>>>
        >>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<<<<<<<<<
        <<<<[>>>>+>>+<<<<<<-]>>>>[<<<<+>>>>-]>>[>+>+<<-]>>[<<+>>-]<<[->+>>+<<[[>+<-]>>[-
        ]<<]>[<+>-]>[<+<<[-]>>>[-]]<<<]>[-]>[<<+>>-]<<[[-]<<<<<<[>>>>>>+<<<<<<-]>[>>>>>>
        +<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<>>>>>>>>>>>>>>>++++[<<<<<<<<
        <<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]>+<<[>>-<<[>+<-]]>[<+>-]<->]<<<<
        [>>>>>+<<[>>-<<[>+<-]]>[<+>-]<-<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[-]<[
        >+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[-]<<<<<<<<<<<<
        <<>>>>+>>]>>>>>>>>>>>>[<<+<<<<+>>>>>>-]<<[>>+<<-]<<<<[>+>+<<-]>>[<<+>>-]<<[->+>>
        +<<[[>+<-]>>[-]<<]>[<+>-]>[<+<<[-]>>>[-]]<<<]>[-]>[<<+>>-]<<[[-]>>>>>>[>>>>>>+<<
        <<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<>>>>>>>>>>>>>>
        >++++[<<<<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]>+<<[>>-<<[>+<-]]>
        [<+>-]<->]<<<<[>>>>>+<<[>>-<<[>+<-]]>[<+>-]<-<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]
        <<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[
        -]<<<<<<<<<<<<<<<<<<<<<<+>>]>>>>>>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>
        >>-]>[<<<<<<+>>>>>>-]<<<<<<<<<<<<<<<<<<<<<[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>
        >>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>><<[<+<+>>-]>>>>>>[[-]<<<<<<<<->>>>>>>>]<<<<>>>>>
        >>>>>-[<<<<[>>>>[-]>>+<<<<<<-]>>>>>>[<<<<<<+>>>>>>-]<<[-[>>+<<-]<<<<<<+>>[-]>[<+
        >-]>[<+>-]>[<+>-]<<<>>>>]>>[<<+>>-]<<]<<<<<<+>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]
        >[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<
        <<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<<<<<<<<<[>>>>>>>>>>>>>>>>>>>>[-]>[<+>-]>[<+>-]>
        [<+>-]<<<<<<<<<<<<<<<+[[-]>>>>>>>>>>>>>>>+<<<<<<<<<[<<+<<<<+>>>>>>-]<<[>>+<<-]>>
        >[<<<+<<<+>>>>>>-]<<<[>>>+<<<-]>>>>[<<<<+<<+>>>>>>-]<<<<[>>>>+<<<<-]>>>>>[<<<<<+
        <+>>>>>>-]<<<<<[>>>>>+<<<<<-]>><<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>
        >>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>++++[<<<<<<<<<<<<[>>>>>>>>
        >+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]>+<<[>>-<<[>+<-]]>[<+>-]<->]<<<<[>>>>>+<<[>>-
        <<[>+<-]]>[<+>-]<-<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[-]<[>+<-]<[>+<-]<
        [>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<<<+>>[<<[-]>>[-]]<<]>>>>>>>>
        >>>>>>>-<<<<<<<<<[<<+<<<<+>>>>>>-]<<[>>+<<-]>>>[<<<+<<<+>>>>>>-]<<<[>>>+<<<-]>>>
        >[<<<<+<<+>>>>>>-]<<<<[>>>>+<<<<-]>>>>>[<<<<<+<+>>>>>>-]<<<<<[>>>>>+<<<<<-]>><<<
        <<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<<
        <<<<<>>>>>>>>>>>>>>>++++[<<<<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-
        ]<+>>+<<[>>-<<[>+<-]]>[<+>-]]<<<<[>>>+>>+<<[>>-<<[>+<-]]>[<+>-]<<<<-]<<<>>>[-]<[
        >+<-]<[>+<-]<[>+<-]<<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>
        >>>>>>>>>>-]>>>-]<[-]<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>[-]<[>+<-]<[>+<-]<[>+<-]
        <<<<<<<<<<<<<<-]>>>>>>>>>>>>>>[-]>[-]>[-]>[-]>>>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-
        ]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<
        <<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<
        <+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<<<<<<<<<<<[[-]>>>>>>>>>>[>>>>>>+<<<<<<-]>[>>
        >>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>>><<<<<<>>>>>>>>>>>>>>>++++[<<<<
        <<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>>>>>>>>>>>[<+>-]<[[-]>+<<[>>-<<[>+<-]]>[<+>-]<->]
        <<<<[>>>>>+<<[>>-<<[>+<-]]>[<+>-]<-<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[
        -]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>>>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[-]<<<<<<<<
        <<<<<<<<<<<<<<<<]>[[-]>>>>>>>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-
        ]>[>>>>>>+<<<<<<-]>>>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+
        <<<<<<-]>>><<<<<<<<<<<<<<<<<<[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>[>>>>>>+<<<<<<-]>
        [>>>>>>+<<<<<<-]>>><<<<<<>>>>>>>>>>>>>>>++++[<<<<<<<<<<<<[>>>>>>>>>+<<<<<<<<<-]>
        >>>>>>>>>>[<+>-]<[[-]>+<<[>>-<<[>+<-]]>[<+>-]<->]<<<<[>>>>>+<<[>>-<<[>+<-]]>[<+>
        -]<-<<<-]<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]<<<<<<>>>[-]<[>+<-]<[>+<-]<[>+<-]>>>>>>>>
        >>>>[<<<<<<<<<<<<+>>>>>>>>>>>>-]>>>-]<[-]<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>[<<<<<<
        +>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<[<<<<<<+>>>
        >>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<<<<<<<<<<]>>>[<
        <<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<<>>>>>>
        >>>>>>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<
        <<<<<<<<
    }
    = M S L 0 | 0 1 | `R0 R1 R2 R3 | 0 0 | Q0 Q1 Q2 Q3
    clear out remainder
    [-]>[-]>[-]>[-]>>>
    = M S L 0 | 0 1 | 0 0 0 0 | 0 0 | `Q0 Q1 Q2 Q3
    word/move_left{ [<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]>[<<<<<<+>>>>>>-]<<<<<<<<< }
    = M S L 0 | 0 1 | `Q0 Q1 Q2 Q3 | 0 0 | 0 0 0 0
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

report_bad_op(10)
bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    = M S L 0 | 0 1 | `* * * *
    [-][ print "BAD_OP" ]
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++++++
    ++++++.
    -.
    +++.
    ++++++++++
    ++++++++++
    +++++++.
    ----------
    ------.
    +.
    [-]
    Abort
    <<<<<<
    abort( [-]+>[-]+>[-]+>>>[-]> )
    = 1 1 1 0 | 0 0 | `* * * *
bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

bfstack/mod_end{ [>[-]++++<[-]]]]<[>+<-]> }

= ~

bfstack/footer{
[>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<[
>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+>[-][]++++++++++++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.[-]++>++>+>>
>><<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>><<<<<<<<]]<[>+<-]>[>[
-]+++++<[-]]]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>
-<]>[<+>-]<[->+>[-][]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++.[-]<<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]>
[>[-]++++<[-]]]]<[>+<-]>[>[-]+++<[-]]>[<+>-]<+[>+<-[[<+>-]>-<]>[<+>-]<[->+<]]<[>
+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+<+[-<<<<<<+>[[-]<->]<]>+<<<+<<[<<+<<<<<<+>>>>>>
>>-]<<[>>+<<-]>>>[>>+<<<<<+>>>-]>>[<<+>>-]<[>+>+<<-]>[<+>-]>>+[->>>>>+>[[-]<->]<
[>+<-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>>>+<<<<<<-]>>>>>>>>
>>>>>>>>>>>]+<<[-]<[-]<[-]<[-]>>>>[<<+>>-]<<<<<<[>>>+<<<-]<<<<<<[>>>>>>>>+<<<<<<
<<-]>>>>>>>>>>>>]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-[-][]++++++++++.++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++.+++++++++++.-.---------.---------
--------------------------------------------------.[-]]]<[>+<-]>[>+<-[[<+>-]>-<]
>[<+>-]<[-[-][]+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++.+++++++++++++..+++++++++++++.-----------------------------.-.+++.++++++++++
+++++++++++++++++.------------------.++.-----------.----------------------------
------------------------------.[-]]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-[-][]+++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++.+++++++++++++..
+++++++++++++.-----------------------------.-.+++.+++++++++++++++++++++++++++.--
----------.++.-------------------.----------------------------------------------
----------.[-]]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-[-][]+++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++.+++++++++++++..+++++++++++++.------
-----------------------.-.+++.+++++++++++++++++++++++++++.-------------------.--
---------.+.+++.+++++++.--------------------------------------------------------
----------.[-]]]<[>+<-]>[>[-][]+++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++.+++++++++++++..+++++++++++++.-----------------------------.
-.+++.+++++++++++++++++++++++++++.----------------------------.++++++++++++.----
-------.+.++++++++++++++++++++++++++.-------------------------------------------
----<[>+<-]>+++++.--------------------------------------.[-]<[-]]>]
}
