[
This file shows how case statements work, a core building block of BFStack.

A case statement will conditionally run one of many blocks of code depending on the input value.
They require three cells. The left and right cells are zero and the center cell contains which
branch you want to run (starting at 1). The branch is counted down and when it hits 1 that branch is
run. Thereafter it is left at zero and no more branches are run. The branch that is run can stick a
value in the right cell which will not be touched afterwords.
]

>

this is the start of a single case block (NOT the start of a whole case statement)
start{
= 0 `X 0
    only consider running this block if X is not 0
    [
        bump the right cell to 1 for use in a moment
        >+<
        decrement X
        -
        = 0 `X_dec 1
        if X_dec is not zero move it to the left cell and clear the 1 in the right cell
        [[<+>-]>-<]
        the right cell (is_hit) is now 1 if and only if X was exactly 1 (else it's 0)
        = X_dec `0 is_hit
        move is_hit to the middle
        >[<+>-]<
        = X_dec `is_hit 0
        only continue if is_hit is one
        [
        clear is_hit
        -
        /= 0 `0 0 (prop tests fail but it is true
}start

end{
        ]
        = X_dec `0 *
    ]
    copy X_dec back to the center position
    <[>+<-]>
    = 0 `X_dec *
}

[-]

[
    default{ <-> }
    fallthrough{ <+> }
]

TEST: runs a branch
= ~
<[-]>[-]>[-]>[-]>[-]<<<

+++
= 0 `3 0 0 0

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>>+<<<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>>++<<<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>>++++<<<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>>++++++++<<<
end{ ]]<[>+<-]> }

= 0 `0 0 0 4

TEST: the 3rd cell is not touched after the branch is run
= ~
<[-]>[-]>[-]>[-]>[-]<<<

++
= 0 `2 0 0

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >++++++++++++<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
end{ ]]<[>+<-]> }

= 0 `0 12

TEST: runs the first branch
= ~
<[-]>[-]>[-]>[-]>[-]<<<

+
= 0 `1 0 0 0

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>>+<<<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>>++<<<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>>++++<<<
end{ ]]<[>+<-]> }

= 0 `0 0 0 1

TEST: can have default
= ~
<[-]>[-]>[-]>[-]>[-]<<<

+++++++
= 0 `7 0 0

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>+<<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >>++<<
end{ ]]<[>+<-]> }

[
    >++<[-]
]

= 0 `0 2

TEST: can fall through to default
= ~
<[-]>[-]>[-]>[-]>[-]<<<

++
= 0 `2 0 0 0

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >+<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    default{ <-> }
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >+++<
end{ ]]<[>+<-]> }

[
    >+++++<[-]
]

= 0 `0 5

TEST: can fall through
= ~
<[-]>[-]>[-]>[-]>[-]<<<

++
= 0 `2 0 0 0

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >+<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    fallthrough{ <+> }
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >+++<
end{ ]]<[>+<-]> }

start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
    >++++<
end{ ]]<[>+<-]> }

[
    >+++++<[-]
]

= 0 `0 3
