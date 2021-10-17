[
Allocate heap memory (see dynamic-memory.md)

use "case.bf"
use "decrement_word.bf"
]

>>>>>> >>>>>> >>>>>> >>
>>>>>> >>>>> +++ >>>>>> +++
<<<<<< <<<<<< <<<<<
= 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 3

Takes a word argument that is the size and returns the address of a newly allocated memory block with that size
try_alloc{
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
    >>+<+
    = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | 0 0 0 0 | `1 1
    now we carry the size argument to the start of the heap
    [
        = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | 0 0 0 0 | `!0 * | 0 0 0 0 | 0 a
        drag_arg{
            [-] in practice it's always 1 but assuming that screws up the tests
            <<<<<<[>>>>>>+<<<<<<-]
            <<<<<<[>>>>>>+<<<<<<-]
            <<<<<<[>>>>>>+<<<<<<-]
            <<<<<<[>>>>>>+<<<<<<-]
            = `0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 * | 0 0 0 0 | 0 a
            >>>>>> >>>>>> >>>>>> >>>>>> >>>>>>+
        }
        = 0 * | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 * | 0 0 0 0 | `1 a
        >[
            If a is not zero it should be 3 which means we've hit the start of the heap
            = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 * | 0 0 0 0 | 1 `!0
            <[-]>[-]
            = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 * | 0 0 0 0 | 0 `0
        ]<
        = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 * | 0 0 0 0 | `keep_going 0
        at this point we'll exit IFF we hit the start of the heap
    ]
    = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 * | 0 0 0 0 | `0 0
    restore the 3 that marks the start of the heap (except it's actually 4 until the start of the loop)
    >++++
    = A0 * | * * * * | A1 * | * * * * | A2 * | 0 0 0 0 | A3 * | 0 0 0 0 | 0 `4
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
                    = ~
                    = is_start 0 | * * * * | 0 `!0
                    [-]
                    <<<<<<+
                    = is_start `1 | * * * * | 0 0
                    <[>[-]<[-]]>
                    = * * | * * * * | 0 `keep_going | * * * * | 0 0
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
    = 0 `2 | 0 0 0 0 | 0 0 | B0 B1 B2 B3
    the most significant digit of return address starts at 1
    the addresses where it is 0 are reserved for stack references
    = 0 `2 | 0 0 0 0 | 0 0 | B0 B1 B2 B3 | 0 * | * * * * | 0 * | * * * * | 0 *
    >>>>>+<<<<<
    = 0 `2 | 0 0 0 0 | 1 0 | B0 B1 B2 B3 | 0 * | * * * * | 0 * | * * * * | 0 *
    the loop ends when we hit a 3 so the current cell is always the code minus 3
    ---
    = 0 `255 | 0 0 0 0 | 1 0 | B0 B1 B2 B3 | 0 * | * * * * | 0 * | * * * * | 0 *
    move to the start counting as we go
    [
        = 0 * | * * * * | 0 `C_minus_3 | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
        restore C
        +++<
        move the expanded address
        move_expanded_value_left{ >>>>>>[<<<<<<+>>>>>>-] }
        move_expanded_value_left{ >>>>>>[<<<<<<+>>>>>>-] }
        move_expanded_value_left{ >>>>>>[<<<<<<+>>>>>>-] }
        move_expanded_value_left{ >>>>>>[<<<<<<+>>>>>>-] }
        = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | `0 * | * * * * | 0 *
        if A0 is nonzero the address is not null so increment it
        <<<<<< <<<<<< <<<<<< <<<<<<
        = `A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 0 * | * * * * | 0 *
        [
            increment the address
            >>>>>> >>>>>> >>>>>> +
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | `A3_inc * | * * * * | 0 * | * * * * | 0 *
            copy A3_inc
            [>>>>>> + >>>>>> + <<<<<< <<<<<< -]
            >>>>>> [<<<<<< + >>>>>> -]
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3_inc * | * * * * | `0 * | * * * * | A3_inc *
            test if A3_inc is zero
            +>>>>>>[<<<<<<[-]>>>>>>[-]]<<<<<<
            = A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3_inc * | * * * * | `A3_inc_is_zero * | * * * * | 0 *
            [
                [-]
                <<<<<< <<<<<< +
                = A0 * | * * * * | A1 * | * * * * | `A2_inc * | * * * * | A3_inc * | * * * * | 0 * | * * * * | 0 *
                copy A2_inc
                [>>>>>> >>>>>> + >>>>>> + <<<<<< <<<<<< <<<<<< -]
                >>>>>> >>>>>> [<<<<<< <<<<<< + >>>>>> >>>>>> -]
                = A0 * | * * * * | A1 * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | `0 * | * * * * | A2_inc *
                test if A2_inc is zero
                expanded_test_if_zero{ +>>>>>>[<<<<<<[-]>>>>>>[-]]<<<<<< }
                = A0 * | * * * * | A1 * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | `A2_inc_is_zero * | * * * * | 0 *
                [
                    [-]
                    <<<<<< <<<<<< <<<<<< +
                    = A0 * | * * * * | `A1_inc * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | 0 * | * * * * | 0 *
                    copy A1_inc
                    [>>>>>> >>>>>> >>>>>> + >>>>>> + <<<<<< <<<<<< <<<<<< <<<<<< -]
                    >>>>>> >>>>>> >>>>>> [<<<<<< <<<<<< <<<<<< + >>>>>> >>>>>> >>>>>> -]
                    = A0 * | * * * * | A1_inc * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | `0 * | * * * * | A1_inc *
                    test if A1_inc is zero
                    expanded_test_if_zero{ +>>>>>>[<<<<<<[-]>>>>>>[-]]<<<<<< }
                    = A0 * | * * * * | A1_inc * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | `A1_inc_is_zero * | * * * * | 0 *
                    [
                        [-]
                        <<<<<< <<<<<< <<<<<< <<<<<< +
                        = `A0_inc * | * * * * | A1_inc * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | 0 * | * * * * | 0 *
                        if A0 overflowed than the address is null and incrementing it each move will stop
                        no need to check that here
                        >>>>>> >>>>>> >>>>>> >>>>>>
                        = A0_inc * | * * * * | A1_inc * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | `0 * | * * * * | 0 *
                    ]
                ]
            ]
            = 0 * | * * * * | A0_inc * | * * * * | A1_inc * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | `0 *
            move A0_inc left so we can end on it's old cell
            <<<<<< <<<<<< <<<<<< <<<<<<
            [<<<<<<+>>>>>>-]
            = A0_inc * | * * * * | `0 * | * * * * | A1_inc * | * * * * | A2_inc * | * * * * | A3_inc * | * * * * | 0 *
        ]
        = A0 * | * * * * | `0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
        move A0 back into place
        <<<<<<[>>>>>>+<<<<<<-]>
        = 0 `C | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
        subtract 3 from C so the loop stops when it hits a 3
        ---
        = 0 `C_minus_3 | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
    ]
    = 0 `0 | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
    set the cell at the start of the heap to 2 so it will end up 3 after being incremented in the loop
    ++
    = 0 `2 | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
    drag the value back to the 1 that marked our starting point
    [
        = 0 * | * * * * | 0 `start_dec | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
        +<
        = 0 * | * * * * | `0 start | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
        >>>>>>[<<<<<<+>>>>>>-]
        >>>>>>[<<<<<<+>>>>>>-]
        >>>>>>[<<<<<<+>>>>>>-]
        >>>>>>[<<<<<<+>>>>>>-]
        <<<<<< <<<<<< <<<<<< <<<<<< <<<<< -
        = 0 `* | * * * * | A0 start | * * * * | A1 * | * * * * | A2 * | * * * * | A3 * | * * * * | 0 *
    ]
    we've hit a cell with value 1 and we can leave it 0 now
    compress down the result address
    = 0 * | 0 0 0 0 | 0 `0 | * * * * | A0 * | * * * * | A1 * | * * * * | A2 * | * * * * | A3 *
    >>>>>[<<<<<< <<<< + >>>>>> >>>> -]
    >>>>>>[<<<<<< <<<<<< <<< + >>>>>> >>>>>> >>> -]
    >>>>>>[<<<<<< <<<<<< <<<<<< << + >>>>>> >>>>>> >>>>>> >> -]
    >>>>>>[<<<<<< <<<<<< <<<<<< <<<<<< < + >>>>>> >>>>>> >>>>>> >>>>>> > -]
    <<<<<< <<<<<< <<<<<< <<<<<< <<<<
    = 0 * | `A0 A1 A2 A3 | 0 0 | * * * * | 0 * | * * * * | 0 * | * * * * | 0 * | * * * * | 0 *
}

TEST: can make first allocation
/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0 | 0 0 0 0 | 0 0

/= `0 0 0 0 | 0 0 | 0 0 0 0 | 0 3 | 0 0 0 0 | 0 2 | 0 0 0 1 | 0 0 | 0 0 0 0 | 0 3
