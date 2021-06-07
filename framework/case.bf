[
This file shows how case statements work, a core building block of BFStack.

They require three cells. The left and right cells are zero and the center cell contains which
branch you want to run (starting at 1). The branch is counted down and when it hits 1 that branch is
run. Thereafter it is left at zero and no more branches are run. The branch that is run can stick a
value in the right cell which will not be touched.
]

>

= 0 `X 0
start{
    [
        >+<-
        = 0 `X_dec 1
        [[<+>-]>-<]
        = X_dec `0 is_hit
        >[<+>-]<
        = X_dec `is_hit 0
        [-

}
    /= 0 `0 0 (prop tests fail but this is what it is)
end{
        ]
        = X_dec `0 *
    ]
    <[>+<-]>
    = 0 `X_dec *
}
= 0 `X_dec *

[-]

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
