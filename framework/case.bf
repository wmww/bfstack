[
This file shows how case statements work, a core building block of BFStack.

They require three cells. The left and right cells are zero and the center cell contains which
branch you want to run. The branch is counted down and when it hits 1 that branch is run. Thereafter
it is left at zero and no more branches are run.
]

>

= 0 `X 0
case_start{ [[<+>-]+<-[>-]>[- }
    = 0 `0 0
case_end{ >]<]<[>+<-]> }
= 0 `X_minus_1_or_0 0

[-]
= ~

+++
= 0 `3 0 0 0

case_start{ [[<+>-]+<-[>-]>[- }
    >>>+<<<
case_end{ >]<]<[>+<-]> }

case_start{ [[<+>-]+<-[>-]>[- }
    >>>++<<<
case_end{ >]<]<[>+<-]> }

case_start{ [[<+>-]+<-[>-]>[- }
    >>>++++<<<
case_end{ >]<]<[>+<-]> }

case_start{ [[<+>-]+<-[>-]>[- }
    >>>++++++++<<<
case_end{ >]<]<[>+<-]> }

= 0 `0 0 0 4
