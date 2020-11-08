from errors import TooFarLeftError
from typing import List

MAX_PRINT_LEN = 64

class Tape:
    def __init__(self, position: int, data: List[int]):
        assert position >= 0
        self._position = position
        self._data = data

    def __str__(self):
        result = []
        data = self._data
        pos = self._position
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

    def get_value(self, offset: int) -> int:
        i = self._position + offset
        if i < 0:
            raise TooFarLeftError()
        elif i >= len(self._data):
            return 0
        else:
            return self._data[i]

    def set_value(self, offset: int, value: int):
        value = value % 256
        i = self._position + offset
        if i < 0:
            raise TooFarLeftError()
        while i >= len(self._data):
            self._data.append(0)
        self._data[i] = value

    def move_by(self, delta: int):
        if -delta > self._position:
            raise TooFarLeftError()
        self._position += delta
