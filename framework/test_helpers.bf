[
Tools to help writing tests
]

clears a large section of the tape for tests
clear{
    = `* * * * | * * | * * * *
    [-]->[-]>[-]>[-]
    ++++++[<++++++[<++++++>-]>-]<<
    = 255 `216 0 0 | * * | * * * * ~
    [>[-]<[>+<-]>-]
    +[[-]<+]
    = `0 0 0 0 | 0 0 | 0 0 0 0
}

TEST: clear clears to right
= `0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0
+++>>+++++>>>-->>>>>++++++++++>>>>>>++
<<<<<<<<<<<<<<
= 3 0 | `5 0 0 254 | 0 0 | 0 0 10 0 | 0 0 | 0 0 2 0 ~
clear{ [-]->[-]>[-]>[-]++++++[<++++++[<++++++>-]>-]<<[>[-]<[>+<-]>-]+[[-]<+] }
= 3 0 | `0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0
