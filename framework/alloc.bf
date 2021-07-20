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
        [-] in practice it's always 1 but assuming that screws up the tests
        <<<<<<[>>>>>>+<<<<<<-]
        <<<<<<[>>>>>>+<<<<<<-]
        <<<<<<[>>>>>>+<<<<<<-]
        <<<<<<[>>>>>>+<<<<<<-]
        = `0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | 0 a
        >>>>>> >>>>>> >>>>>> >>>>>> >>>>>>+
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
    >+++
    = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | 0 `3
}

TEST: can make first allocation
/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0

/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 2 | 0 0 0 1 | 0 0 | 0 0 0 0 | 0 3
