from errors import ProgramError, TestError, OffEdgeOfTestTapeError
from typing import List, Optional

MAX_PRINT_LEN = 64

class Tape:
    def __init__(self, position: int, data: List[int], hard_left_boundry: bool, is_test_tape: bool):
        self._position = position # Logical data tape position
        self._left_frontier = position # Logical data tape position, farthest left been or looked at
        self._right_frontier = position # Logical data tape position, farthest right been or looked at
        self._hard_left_boundry = hard_left_boundry # If the logical data tape position 0 is the limit
        self._left_bound: Optional[int] = None # Logical data tape position
        self._right_bound: Optional[int] = None # Logical data tape position
        self._data = data # The actual data, expanded on write only
        self._offset_to_data = 0 # Add this to a logical position to get a _data index, + means data starts before 0
        self._is_test_tape = is_test_tape # test tapes can not be dynamically expanded with 0s
        self.check_offset_allowed(0)

    def __str__(self):
        result = ''

        left_edge = min(0, self._left_frontier)
        if self._left_bound:
            left_edge = min(left_edge, self._left_bound)
        left_edge = max(left_edge, self._position - MAX_PRINT_LEN)

        right_edge = self._right_frontier + 1
        if self._right_bound:
            right_edge = max(right_edge, self._right_bound + 1)
        right_edge = min(right_edge, self._position + MAX_PRINT_LEN)

        if left_edge > 0:
            result += '| (' + str(left_edge) + ' cells) …'
        for i in range(left_edge, right_edge):
            if i == 0:
                if result:
                    result += ' '
                result += '|'
            if i == self._left_bound:
                result += ' [ '
            elif i - 1 == self._right_bound:
                result += ' ] '
            else:
                result += ' '
            if i == self._position:
                result += '`'
            result += str(self._get_value_unchecked_absolute(i))
        if right_edge - 1 == self._right_bound:
            result += ' ]'
        right_chop = len(self._data) - self._offset_to_data - right_edge
        if right_chop > 0:
            result += ' … (' + str(right_chop) + ' cells)'
        return result

    def get_position(self) -> int:
        return self._position

    def check_offset_allowed(self, offset: int):
        pos = self._position + offset
        self._left_frontier = min(pos, self._left_frontier)
        self._right_frontier = max(pos, self._right_frontier)
        if self._left_bound is not None and pos < self._left_bound:
            raise TestError('Too far left for previous assertion')
        elif self._right_bound is not None and pos > self._right_bound:
            raise TestError('Too far right for previous assertion')
        if self._hard_left_boundry and self._position + offset < 0:
            raise ProgramError('Went off the left edge of the tape')
        if self._is_test_tape:
            i = pos + self._offset_to_data
            if i < 0 or i >= len(self._data):
                raise OffEdgeOfTestTapeError('')

    def check_range_allowed(self, left_offset: int, right_offset: int):
        # If left and right are both allowed, the whole range must be
        self.check_offset_allowed(right_offset)
        self.check_offset_allowed(left_offset)

    def set_assertion_bounds(self, left_offset: Optional[int], right_offset: Optional[int]):
        '''The furthest left and right allowed (inclusive)'''
        self._left_bound = None if left_offset is None else self._position + left_offset
        self._right_bound = None if right_offset is None else self._position + right_offset
        self.check_offset_allowed(0)

    def _get_value_unchecked_absolute(self, logical_position: int) -> int:
        i = logical_position + self._offset_to_data
        if i >= len(self._data) or i < 0:
            return 0
        else:
            return self._data[i]

    def get_value(self, offset: int) -> int:
        self.check_offset_allowed(offset)
        return self._get_value_unchecked_absolute(offset + self._position)

    def set_value(self, offset: int, value: int):
        self.check_offset_allowed(offset)
        value = value % 256
        i = offset + self._position + self._offset_to_data
        while i < 0:
            self._offset_to_data += 100
            i = offset + self._position + self._offset_to_data
        while i >= len(self._data):
            self._data.append(0)
        self._data[i] = value

    def move_by(self, delta: int):
        self._position += delta
        self.check_offset_allowed(0)
