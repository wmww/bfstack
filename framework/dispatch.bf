[
This file contains the boilerplate snippets for building modules and subroutines. The big idea is a
big case statement selects the correct module, then another case statement selects the right
subroutine, then a final one selects the correct label. The abstraction that this file exposes is
composed a little differently than the building blocks. The snippets are as follows:

mod_start: begins a new module
mod_end: ends a module
sub_start: begins a new subroutine (contains the case for both subroutine and the first label)
sub_end: ends a subroutine (and also the last label)
invoke: ends a label, and starts the next one (which causes the specified subroutine to be invoked)

use "case.bf"
]

M: module
S: subroutine
L: label (within subroutine)

>>>>

= M S L 0 | `M 0

mod_start{
case/start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    = M S L 0 | `0 0
    copy_S{ <<<[>>+>+<<<-]>>[<<+>>-]> }
    }mod_start

    sub_start{
    = M S L 0 | `S 0
    case/start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
        = M S L 0 | `0 0
        copy_L{ <<[>+>+<<-]>[<+>-]> }
        = M S L 0 | `L 0
        case/start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
            = M S L 0 | `0 0 | * * * *
            >+>
            }sub_start
            = M S L 0 | 0 1 | `* * * *

            = ~
            = `0 0 0 0 | 0 0 | 0 0 0 0
            >>+>>>>
            note that this M and S are those of the subroutine we're invoking
            = M S 1 0 | 0 0 | `0 0 0 0

            invoke{
            <<
        case/end{ ]]<[>+<-]> }
        = M S L 0 | `* 0
        case/start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
            = ~
            = !0 !0 !0 0 | `0 0 | * * * *
            <<<<[-]>[-]>[-]>>>>
            = 0 0 0 0 | 0 0 | `* * * *
            }invoke

            = ~
            <<<<<<

            sub_end{
            <<
            = M S L 0 | `0 1 |
        case/end{ ]]<[>+<-]> }
        = M S L 0 | `* *

        if there's still a value the throw "no such label" (return code 5)
        [>[-]+++++<[-]]
        = M S L 0 | `0 C

    case/end{ ]]<[>+<-]> }
    = M S L 0 | `* *
    }sub_end

    mod_end{
    if there's still a value the throw "no such subroutine" (return code 4)
    end_mod{ [>[-]++++<[-]] }
    = M S L 0 | `0 C
case/end{ ]]<[>+<-]> }
= M S L 0 | `* *
}mod_end

= ~

TEST: runs 1::1::1
= `0 0 0 0 | 0 0 | 0
+>+>+>>+
the 1 on the current cell would normally have been copied from the module index
= 1 1 1 0 | `1 0 | 0
mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]> }
    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
        = 1 1 1 0 | 0 1 | `0
        set first return value to 3 and leave everything else untouched
        +++
        = 1 1 1 0 | 0 1 | `3
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }
mod_end{ [>[-]++++<[-]]]]<[>+<-]> }
= 1 1 1 0 | `0 1 | 3

clear out relevant section of tape
>>[-]<[-]<<<[-]<[-]<[-]

TEST: runs 2::3::1
= `0 0 0 0 | 0 0 | 0
++>+++>+>>++
the 2 on the current cell would normally have been copied from the module index
= 2 3 1 0 | `2 0 | 0
mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]> }
    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }
mod_end{ [>[-]++++<[-]]]]<[>+<-]> }

mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]> }
    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
        = 2 3 1 0 | 0 1 | `0
        set first return value to 7 and leave everything else untouched
        +++++++
        = 2 3 1 0 | 0 1 | `7
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }

    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }
mod_end{ [>[-]++++<[-]]]]<[>+<-]> }
= 2 3 1 0 | `0 1 | 7

clear out relevant section of tape
>>[-]<[-]<<<[-]<[-]<[-]

TEST: can invoke
= `0 0 0 0 | 0 0 | 0
+>+>+>>+
the 1 on the current cell would normally have been copied from the module index
= 1 1 1 0 | `1 0 | 0
mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]> }
    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
        = 1 1 1 0 | 0 1 | `0 0 0 0 | 0 0 | 0
        ++>+++>+>>>>
        = 1 1 1 0 | 0 1 | 2 3 1 0 | 0 0 | `0
        invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }
mod_end{ [>[-]++++<[-]]]]<[>+<-]> }
= 2 3 1 0 | `0 0 | 0

clear out relevant section of tape
>>[-]<[-]<<<[-]<[-]<[-]

TEST: can jump to label 2
= `0 0 0 0 | 0 0 |
+>+>++>>+
the 1 on the current cell would normally have been copied from the module index
=  1 1 2 0 | `1 0 | 0
mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]> }
    sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
        invoke{ <<]]<[>+<-]>[>+<-[[<+>-]>-<]>[<+>-]<[-<<<<[-]>[-]>[-]>>>> }
        = 0 0 0 0 | 0 0 | `0
    sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }
mod_end{ [>[-]++++<[-]]]]<[>+<-]> }
= 0 0 0 0 | `0 0 | 0
