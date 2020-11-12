from errors import ProgramError, TestError
from typing import List, Optional

MAX_PRINT_LEN = 64

class Tape:
    def __init__(self, position: int, data: List[int], hard_left_boundry: bool):
        assert position >= 0
        self._position = position
        self._hard_left_boundry = hard_left_boundry
        self._left_bound: Optional[int] = None
        self._right_bound: Optional[int] = None
        self._data = data
        self._offset_to_data = 0 # What you add to position before indexing into data
        self.check_offset_allowed(0)

    def __str__(self):
        result = []
        data = self._data
        pos = self._position + self._offset_to_data
        start = ''
        end = ''
        if pos > MAX_PRINT_LEN:
            chop = pos - MAX_PRINT_LEN
            data = data[chop:]
            pos = MAX_PRINT_LEN
            start = '(' + str(chop) + ' cells) … '
        if len(data) > pos + MAX_PRINT_LEN:
            chop = len(data) - pos - MAX_PRINT_LEN
            data = data[:-chop]
            end = ' … (' + str(chop) + ' cells)'
        while len(data) - 1 < pos:
            data.append(0)
        for i, cell in enumerate(data):
            if i == pos:
                result.append('`' + str(cell))
            else:
                result.append(str(cell))
        return start + ' '.join(result) + end

    def get_position(self) -> int:
        return self._position

    def data_index_for(self, offset: int) -> int:
        return self._position + self._offset_to_data + offset

    def check_offset_allowed(self, offset: int):
        pos = self._position + offset
        if self._left_bound is not None and pos < self._left_bound:
            raise TestError('Too far left for previous assertion')
        elif self._right_bound is not None and pos > self._right_bound:
            raise TestError('Too far right for previous assertion')
        if self._hard_left_boundry and self._position + offset < 0:
            raise ProgramError('Went off the left edge of the tape')

    def check_range_allowed(self, left_offset: int, right_offset: int):
        # If left and right are both allowed, the whole range must be
        self.check_offset_allowed(right_offset)
        self.check_offset_allowed(left_offset)

    def set_assertion_bounds(self, left_offset: Optional[int], right_offset: Optional[int]):
        '''The furthest left and right allowed (inclusive)'''
        self._left_bound = None if left_offset is None else self._position + left_offset
        self._right_bound = None if right_offset is None else self._position + right_offset
        self.check_offset_allowed(0)

    def get_value(self, offset: int) -> int:
        self.check_offset_allowed(offset)
        i = self.data_index_for(offset)
        if i >= len(self._data) or i < 0:
            return 0
        else:
            return self._data[i]

    def set_value(self, offset: int, value: int):
        self.check_offset_allowed(offset)
        value = value % 256
        i = self.data_index_for(offset)
        while i < 0:
            self._offset_to_data += 100
            i = self.data_index_for(offset)
        while i >= len(self._data):
            self._data.append(0)
        self._data[i] = value

    def move_by(self, delta: int):
        self.check_offset_allowed(delta)
        self._position += delta
