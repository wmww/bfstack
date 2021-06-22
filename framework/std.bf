[
The BFStack standard library. It resides in module 1.

use "bfstack.bf"
]

>

std{
mod std(1)
bfstack/mod_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<<[>>+>+<<<-]>>[<<+>>-]> }
    sub abort(1)
    bfstack/sub_start{ [>+<-[[<+>-]>-<]>[<+>-]<[-<<[>+>+<<-]>[<+>-]>[>+<-[[<+>-]>-<]>[<+>-]<[->+> }
        = M S L 0 | 0 1 | `* * * *
        set the abort code
        <+>
        = M S L 0 | 0 2 | `*
    bfstack/sub_end{ <<]]<[>+<-]>[>[-]+++++<[-]]]]<[>+<-]> }
bfstack/mod_end{ [>[-]++++<[-]]]]<[>+<-]> }
}
