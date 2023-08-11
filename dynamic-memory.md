# Dynamic Memory

__NOTE: the implementation of what's described here is still a work in progress__

The basic stack-based [architecture](architecture.md) allows for data to be passed from function to function, but all the data must be moved each call and return. This gets quite impractical for large or dynamically sized data, so a dynamic memory management system is built into the standard library. Memory can be allocated, fetched, stored and deallocated.

## The Heap
Allocated dynamic memory is stored in the heap, which is an area of the tape far to the right of the stack. BFStack programs that use dynamic memory should invoke `std::init_heap` to set things up (else the first `std::alloc` will endlessly loop looking for the heap). The heap is structured like so:
```
= (stack and free space) | 0 3 | 0 0 0 0 | (heap) | 0 3 |
```
The heap is made out of sections of arbitrary size. Each section can be used or unused. A section looks like this:
```
= 0 C | 0 0 0 0 | 0 0 | W X Y Z | 0 0 | (data)
```
`C` is the code indicating if and what type of section starts at this word:
- `0`: in the middle of a section
- `1`: start of a free section
- `2`: start of a used section
- `3`: at the start or end of the heap

`W`, `X`, `Y` and `Z` are a 4-cell number that represents the size of the section (in words).

This means a heap that contains one 260-long free section and one 2-long used section will look like this (note that in base-256 260 is represented as `14`):
```
= (stack and free space) | 0 3 | 0 0 0 0 | 0 1 | 0 0 0 0 | 0 0 | 0 0 1 4 | 0 0 | (260 words (1560 cells) of 0s) | 0 2 | 0 0 0 0 | 0 0 | 0 0 0 2 | 0 0 | A B C D | 0 0 | E F G H | 0 3 | 0 0 0 0 | (0s forever)
```

## Addresses
Memory addresses are words, and each point to a specific word in heap memory. Addresses with the most significant cell as `0` are not used, and may in the future refer to stack positions. Heap address 0 (represented `1 0 0 0`) is two words after the initial `3` that starts the heap. Those first two words are always guaranteed to be 0. All other words in the heap are addressable, which means `start_of_allocation - 1` points to the size of the allocation.

## API
- `std::alloc` takes a word as an argument (the size of the allocation) and returns a word (the address of the start of the allocation). It zeros out the memory block. If it fails to allocate, it aborts the program.
- `std::fetch` takes a word as an argument (the address) and returns a word (the value in it). It's not possible to fetch multiple words at once, fetch must be invoked multiple times.
- `std::store` takes two words, first the address and then the value to store in it. It does not return anything.
- `std::dealloc` takes a word (the start of the block to deallocate). It does not return anything.

## Strategy
Alloc searches for the first free section that's the requested size. If it gets to the end of the heap without finding one it creates a new section. Dealloc simply marks the section as free. Once created, sections are never split or resized.
