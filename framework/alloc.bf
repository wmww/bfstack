[
Allocate heap memory (see dynamic-memory.md)

use "case.bf"
]

>>>>>>>>>>>>>>>>>>>>

alloc{
    = 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 0 * | `A0 A1 A2 A3 | 0 0
    first we want to inflate the size argument into the padding
    [<<<<<< <<<<<< <<<<<< << + >>>>>> >>>>>> >>>>>> >> -]
    = A0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 0 * | `0 A1 A2 A3 | 0 0
    >[<<<<<< <<<<<< <<< + >>>>>> >>>>>> >>> -]
    = A0 * | * * * * | A1 * | * * * * | 0 * | * * * * | 0 * | 0 `0 A2 A3 | 0 0
    >[<<<<<< <<<< + >>>>>> >>>> -]
    = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | 0 * | 0 0 `0 A3 | 0 0
    >[<<<<< + >>>>> -]
    = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | 0 0 0 `0 | 0 0
    >+
    = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | 0 0 0 0 | `1 0
    now we carry the size argument to the start of the heap
    [
        = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | 0 0 0 0 | `!0 0 | 0 0 0 0 | 0 a
        drag_arg{
            [-] in practice it's always 1 but assuming that screws up the tests
            <<<<<<[>>>>>>+<<<<<<-]
            <<<<<<[>>>>>>+<<<<<<-]
            <<<<<<[>>>>>>+<<<<<<-]
            <<<<<<[>>>>>>+<<<<<<-]
            = `0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | 0 a
            >>>>>> >>>>>> >>>>>> >>>>>> >>>>>>+
        }
        = 0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | `1 a
        >[
            If a is not zero it should be 3 which means we've hit the start of the heap
            = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | 1 `!0
            <[-]>[-]
            = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | 0 `0
        ]<
        = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | `keep_going 0
        at this point we'll exit IFF we hit the start of the heap
    ]
    = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | `0 0
    restore the 3 that marks the start of the heap
    >+++<+
    = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | `1 3
    now we carry the size argument until we find a correctly sized free slot (or the end of the heap)
    [
        = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | `!0 * | * * * * | 0 a
        drag_arg{
            [-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>
            >>+<<<<<<-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+
        }
        = 0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | `1 a
        >[
            if a is nonzero this is the start of a section and the next two words are empty then section size
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 `a | 0 0 0 0 | 0 0 | B0 B1 B2 B3
            [>+>+<<-]>[<+>-]>
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 a | 0 `a 0 0 | 0 0 | B0 B1 B2 B3
            case::start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
                a == 1 (start of free section)
                TODO: compare required size to actual size
            case::end{ ]]<[>+<-]> }
            case::start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
                a == 2 (start of used section)
                do nothing and continue the search
            case::end{ ]]<[>+<-]> }
            case::start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
                a == 3 (end of heap)
                TODO: expand heap
            case::end{ ]]<[>+<-]> }
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | keep_going a | 0 `* 0 0 | 0 0 | B0 B1 B2 B3
            clear out whatevers left (should be nothing if a was a valid value)
            [-]<<<
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | `keep_going a | 0 0 0 0 | 0 0 | B0 B1 B2 B3
        ]
        = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | `keep_going 0
    ]
}

TEST: can make first allocation
/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0

/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 2 | 0 0 0 1 | 0 0 | 0 0 0 0 | 0 3
