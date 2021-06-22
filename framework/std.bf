[
The BFStack standard library. It resides in module 1.

use "dispatch.bf"
]

>

std{
mod std(1)
dispatch/mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]> }
    sub abort(1)
    dispatch/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
        causes the program to complete
        = M S L 0 | 0 1 | `* * * *
        set the abort code
        <+>
        = M S L 0 | 0 2 | `*
    dispatch/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }
dispatch/mod_end{ [>[-]++++<[-]]]]<[>+<-]> }
}
