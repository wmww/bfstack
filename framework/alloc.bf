[
Allocate heap memory (see dynamic-memory.md)

use "case.bf"
use "decrement_word.bf"
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
    restore the 3 that marks the start of the heap (except it's actually 4 until the start of the loop)
    >++++
    = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 0 | 0 0 0 0 | 0 `4
    now we carry the size argument until we find a correctly sized free slot (or the end of the heap)
    [
        = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 0 `!0 | * * * * | 0 C
        the loop stops at code 255 which means we always start out with the value one more than the real code
        -<
        = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | `0 !255 | * * * * | 0 C
        drag_arg{
            [-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>>>+<<<<<<-]<<<<<<[>>>>
            >>+<<<<<<-]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>+
        }
        = 0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | `1 C
        ->
        = 0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 0 `C
        [
            if C is nonzero this is the start of a section; the next two words are empty then section size
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 0 `C | 0 0 0 0 | 0 0 | B0 B1 B2 B3
            [<+>>+<-]>
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | C 0 | `C 0 0 0 | 0 0 | B0 B1 B2 B3
            case::start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
                C == 1 (start of free section)
                compare required size to actual size
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 0 | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                r (result) will end up 1 if the requested size and size of the section are equal
                <+>
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 1 | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                copy in A0
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                <<<<<< <<<<<< <<<<<< <<<<<< <<
                [>>>>>> >>>>>> >>>>>> >>>>>> >> +>+< <<<<<< <<<<<< <<<<<< <<<<<< << -]
                >>>>>> >>>>>> >>>>>> >>>>>> >>>
                [<<<<<< <<<<<< <<<<<< <<<<<< <<< + >>>>>> >>>>>> >>>>>> >>>>>> >>>-]
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | A0 `0 0 0 | 0 0 | B0 B1 B2 B3
                copy in B0
                >>>>>[<<<<+<+>>>>>-]
                <<<<[>>>>+<<<<-]<<
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `A0 B0 0 0 | 0 0 | B0 B1 B2 B3
                compare{
                    = r `A B
                    subtract A from B leaving B zero only if it was equal to A
                    [->-<]
                    set r to zero if A and B are not equal
                    = r `0 not_equal
                    >[<<[-]>>[-]]<
                    = new_r `0 0
                }
                copy in A1
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                <<<<<< <<<<<< <<<<<< <<
                [>>>>>> >>>>>> >>>>>> >> +>+< <<<<<< <<<<<< <<<<<< << -]
                >>>>>> >>>>>> >>>>>> >>>
                [<<<<<< <<<<<< <<<<<< <<< + >>>>>> >>>>>> >>>>>> >>>-]
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | A1 `0 0 0 | 0 0 | B0 B1 B2 B3
                copy in B1
                >>>>>>[<<<<<+<+>>>>>>-]
                <<<<<[>>>>>+<<<<<-]<<
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `A1 B1 0 0 | 0 0 | B0 B1 B2 B3
                compare{ [->-<]>[<<[-]>>[-]]< }
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 new_r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                copy in A2
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                <<<<<< <<<<<< <<
                [>>>>>> >>>>>> >> +>+< <<<<<< <<<<<< << -]
                >>>>>> >>>>>> >>>
                [<<<<<< <<<<<< <<< + >>>>>> >>>>>> >>>-]
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | A2 `0 0 0 | 0 0 | B0 B1 B2 B3
                copy in B2
                >>>>>>>[<<<<<<+<+>>>>>>>-]
                <<<<<<[>>>>>>+<<<<<<-]<<
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `A2 B2 0 0 | 0 0 | B0 B1 B2 B3
                compare{ [->-<]>[<<[-]>>[-]]< }
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 new_r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                copy in A3
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                <<<<<< <<
                [>>>>>> >> +>+< <<<<<< << -]
                >>>>>> >>>
                [<<<<<< <<< + >>>>>> >>>-]
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | A3 `0 0 0 | 0 0 | B0 B1 B2 B3
                copy in B3
                >>>>>>>>[<<<<<<<+<+>>>>>>>>-]
                <<<<<<<[>>>>>>>+<<<<<<<-]<<
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `A3 B3 0 0 | 0 0 | B0 B1 B2 B3
                compare{ [->-<]>[<<[-]>>[-]]< }
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 new_r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 r | `0 0 0 0 | 0 0 | B0 B1 B2 B3
                whew that was a lot
                r is now 1 if all the digits of the sizes were equal
                if r is one we set C to 255 to abort the search for a free section
                <[
                    = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 1 `r | 0 0 0 0 | 0 0 | B0 B1 B2 B3
                    <[-]->[-]
                    = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 255 `0 | 0 0 0 0 | 0 0 | B0 B1 B2 B3
                    clear out the size argument
                    < <<<<<< <<<<<< <<<<<< <<<<<<
                    [-] >>>>>> [-] >>>>>> [-] >>>>>> [-] >>>>>> >
                    = 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 255 `0 | 0 0 0 0 | 0 0 | B0 B1 B2 B3
                ]>
                if the sizes were not equal we do not touch C (it stays 1)
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | new_C 0 | `0 0 0 0 | 0 0 | B0 B1 B2 B3
            case::end{ ]]<[>+<-]> }
            case::start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
                C == 2 (start of used section)
                do nothing and continue the search for a usable section
            case::end{ ]]<[>+<-]> }
            case::start{ [>+<-[[<+>-]>-<]>[<+>-]<[- }
                C == 3 (end of heap)
                expand the heap
                = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 3 0 | `0 0 0 0
                consolidate size argument
                << <<<<<< <<<<<< <<<<<< <<<<<<
                [>>>>>> >>>>>> >>>>>> >>>>>> >> + << <<<<<< <<<<<< <<<<<< <<<<<< -]
                = `0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 3 0 | A0 0 0 0
                >>>>>>[>>>>>> >>>>>> >>>>>> >>> + <<< <<<<<< <<<<<< <<<<<< -]
                = 0 * | * * * * | `0 * | * * * * | A2 * | * * * * | A3 * | * * * * | 3 0 | A0 A1 0 0
                >>>>>>[>>>>>> >>>>>> >>>> + <<<< <<<<<< <<<<<< -]
                = 0 * | * * * * | 0 * | * * * * | `0 * | * * * * | A3 * | * * * * | 3 0 | A0 A1 A2 0
                >>>>>>[>>>>>> >>>>> + <<<<< <<<<<< -]
                = 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | `0 * | * * * * | 3 0 | A0 A1 A2 A3
                >>>>>> >
                = 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 3 `0 | A0 A1 A2 A3
                copy the size (one copy to stay with the heap and one copy to tell us how far to walk)
                = 3 `0 | A0 A1 A2 A3 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0
                copy_word_value{ >[>>>>>> + >>>>>> + <<<<<< <<<<<< -] }
                copy_word_value{ >[>>>>>> + >>>>>> + <<<<<< <<<<<< -] }
                copy_word_value{ >[>>>>>> + >>>>>> + <<<<<< <<<<<< -] }
                copy_word_value{ >[>>>>>> + >>>>>> + <<<<<< <<<<<< -] }
                >>>>>> >>
                = 3 0 | 0 0 0 0 | 0 0 | A0 A1 A2 A3 | 0 `0 | A0 A1 A2 A3
                move to the right by the specified amount
                +[
                    = 0 `!0 | A0 A1 A2 A3 | 0 0 | 0 0 0 0
                    [-]
                    move_word_value_right{ >[>>>>>> + <<<<<< -] }
                    move_word_value_right{ >[>>>>>> + <<<<<< -] }
                    move_word_value_right{ >[>>>>>> + <<<<<< -] }
                    move_word_value_right{ >[>>>>>> + <<<<<< -] }
                    >>>
                    = 0 0 | 0 0 0 0 | 0 0 | `A0 A1 A2 A3 | 0 0 | 0 0 0 0
                    decrement_word::decrement_word{
                        >>>>>><<<[>>>+>+<<<<-]>>>-[<<<+>>>-]+>[<[-]>[-]]<[[-]<<<<[>>>>+>+<<<<<-]>>>>-[<<
                        <<+>>>>-]+>[<[-]>[-]]<[[-]<<<<<[>>>>>+>+<<<<<<-]>>>>>-[<<<<<+>>>>>-]+>[<[-]>[-]]
                        <[[-]<<<<<<[>>>>>>+>+<<<<<<<-]>>>>>>-[<<<<<<+>>>>>>-]+>[<[-]>[-]]<[>+<-]]]]<<<<<
                        <
                    }
                    = 0 0 | `A0_dec A1_dec A2_dec A3_dec | 0 0 | 0 hit_zero 0 0
                    <+
                    = 0 `1 | A0_dec A1_dec A2_dec A3_dec | 0 0 | 0 hit_zero 0 0
                    >>>>>> >> [<<<<<< << [-] >> >>>>>> [-]] <<<<<< <<
                    = 0 `!hit_zero | A0_dec A1_dec A2_dec A3_dec | 0 0 | 0 0 0 0
                ]
                clear out the overflowed number
                = 0 0 | 0 0 0 0 | 0 `0 | A0_dec A1_dec A2_dec A3_dec
                >[-]>[-]>[-]>[-]<<<<
                = 0 0 | 0 0 0 0 | 0 `0 | 0 0 0 0
                we always overshoot by 1 so go back one word and mark that the new end of tape
                <<<<<<+++
                = 0 0 | * * * * | 0 `3 | 0 0 0 0 | 0 0 | 0 0 0 0
                <<<<<<+
                = * 0 | * * * * | 0 `1 | * * * * | 0 3
                [
                    = is_start 0 | * * * * | 0 `!0
                    [-]
                    <<<<<<+
                    = is_start `1 | * * * * | 0 0
                    <[>[-]<[-]]>
                    = * 0 | * * * * | 0 `keep_going | * * * * | 0 0
                ]
                = ~
                = 0 `0 | 0 0 0 0
                <->>
                = 255 0 | `0 0 0 0
            case::end{ ]]<[>+<-]> }
            = ~
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | C 0 | `* 0 0 0 | 0 0
            clear out whatevers left (should be nothing if a was a valid value)
            [-]<
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | C `0 | 0 0 0 0 | 0 0
        ]
        = 0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | C `0
        <[>+<-]>
        = 0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 0 `C
        the loop should stop when C is 255
        +
        = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 0 `C_inc
    ]
    = 0 `0 | 0 0 0 0 | 0 0 | B0 B1 B2 B3
    assume we've found a free section; it will now be used so mark it with 2
    ++
    = 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 0 `2 | 0 0 0 0 | 0 0 | B0 B1 B2 B3
    TODO: move to the start counting as we go
}

TEST: can make first allocation
/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0

/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 2 | 0 0 0 1 | 0 0 | 0 0 0 0 | 0 3
