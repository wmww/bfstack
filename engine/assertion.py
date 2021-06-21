from instruction import Instruction
from program import Program
from tape import Tape
from assertion_ctx import AssertionCtx
from errors import TestError, OffEdgeOfTestTapeError
from span import Span
from colors import make_color, Color

from typing import Sequence, Optional, List, Set

class AssertionFailedError(TestError):
    def __init__(self, state: 'TapeAssertion', actual_tape: str, ctx: AssertionCtx):
        msg = 'Assertion failed:'
        msg += '\n     Actual: ' + make_color(Color.TAPE, actual_tape)
        msg += '\n  Assertion: ' + make_color(Color.ERROR, str(state))
        if ctx.bound_vars:
            msg += '\n  Variables: ' + make_color(Color.INFO, repr(ctx.bound_vars))
        super().__init__(msg)

class Matcher:
    def __str__(self):
        raise NotImplementedError()

    def bind(self, ctx: AssertionCtx, value: int):
        raise NotImplementedError()

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        raise NotImplementedError()

    def used_variables(self) -> Optional[Set[str]]:
        raise NotImplementedError()

    def random_matching(self, ctx: AssertionCtx) -> int:
        raise NotImplementedError()

class VariableMatcher(Matcher):
    def __init__(self, name: str):
        self._name = name

    def __str__(self):
        return str(self._name)

    def bind(self, ctx: AssertionCtx, value: int):
        if self._name not in ctx.bound_vars:
            ctx.bound_vars[self._name] = value

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        if self._name not in ctx.bound_vars:
            raise TestError('Unbound variable \'' + str(self._name) + '\' can not be matched against ' + str(value))
        return ctx.bound_vars[self._name] == value

    def used_variables(self) -> Optional[Set[str]]:
        return set([self._name])

    def random_matching(self, ctx: AssertionCtx) -> int:
        if self._name in ctx.bound_vars:
            return ctx.bound_vars[self._name]
        else:
            raise TestError('Can not create matching value for unbound variable \'' + str(self._name) + '\'')

class LiteralMatcher(Matcher):
    def __init__(self, text: str, value: int):
        assert value >= 0 and value < 256, 'Invalid literal matcher'
        self._text = text
        self._value = value

    def __str__(self):
        text = self._text
        if text != str(self._value):
            text += ':' + str(self._value)
        return text

    def bind(self, ctx: AssertionCtx, value: int):
        pass

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        return self._value == value

    def used_variables(self) -> Optional[Set[str]]:
        return None

    def random_matching(self, ctx: AssertionCtx) -> int:
        return self._value

class WildcardMatcher(Matcher):
    def __str__(self):
        return '*'

    def bind(self, ctx: AssertionCtx, value: int):
        pass

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        return True

    def used_variables(self) -> Optional[Set[str]]:
        return None

    def random_matching(self, ctx: AssertionCtx) -> int:
        return ctx.random_biased_byte()

class InverseMatcher(Matcher):
    def __init__(self, inner: Matcher):
        self._inner = inner

    def __str__(self):
        return '!' + str(self._inner)

    def bind(self, ctx: AssertionCtx, value: int):
        pass

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        return not self._inner.matches(ctx, value)

    def used_variables(self) -> Optional[Set[str]]:
        return self._inner.used_variables()

    def random_matching(self, ctx: AssertionCtx) -> int:
        for i in range(100):
            v = ctx.random_biased_byte()
            if not self._inner.matches(ctx, v):
                return v
        for i in range(256):
            if not self._inner.matches(ctx, i):
                return i
        raise TestError('Literally nothing matches ' + str(self))

class AssertionReset(Instruction):
    def __init__(self, span: Span):
        self._span = span

    def __str__(self):
        return '= ~'

    def run(self, program: Program):
        program.assertion_ctx.remove_unused_vars(set())
        program.tape.set_assertion_bounds(None, None)

    def loop_level_change(self) -> int:
        return 0

    def ends_assertion_block(self) -> bool:
        return True

    def span(self) -> Span:
        return self._span

class TapeAssertion(Instruction):
    def __init__(
            self, cells: Sequence[Matcher],
            allow_slide_left: bool,
            allow_slide_right: bool,
            offset_of_current: int,
            span: Span):
        self._cells = cells
        self._allow_slide_left = allow_slide_left
        self._allow_slide_right = allow_slide_right
        self._offset_of_current = offset_of_current
        self._span = span
        self._used_variables: Set[str] = set()
        for cell in cells:
            used = cell.used_variables()
            if used is not None:
                self._used_variables = self._used_variables.union(used)

    def __str__(self):
        result = '= '
        if self._allow_slide_left:
            result += '~ '
        for i, cell in enumerate(self._cells):
            if i:
                result += ' '
            if i == self._offset_of_current:
                result += '`'
            result += str(cell)
        if self._allow_slide_right:
            result += ' ~'
        return result

    def apply_bounds_to_tape(self, tape: Tape):
        left_edge = -self._offset_of_current
        right_edge = len(self._cells) - self._offset_of_current - 1
        left = None if self._allow_slide_left else left_edge
        right = None if self._allow_slide_right else right_edge
        tape.set_assertion_bounds(left, right)
        tape.check_range_allowed(left_edge, right_edge)

    def run(self, program: Program):
        program.real_ops += 1 + len(self._cells)

        try:
            self.apply_bounds_to_tape(program.tape)
        except OffEdgeOfTestTapeError:
            # This means this assertion has a bigger range than the previous one in a property test
            pass

        for i, cell in enumerate(self._cells):
            try:
                cell.bind(program.assertion_ctx, program.tape.get_value(i - self._offset_of_current))
            except OffEdgeOfTestTapeError:
                # This cell is off the range of what the tape knows about
                pass

        for i, cell in enumerate(self._cells):
            try:
                if not cell.matches(program.assertion_ctx, program.tape.get_value(i - self._offset_of_current)):
                    raise AssertionFailedError(
                        self,
                        program.tape.range_to_str(-self._offset_of_current, len(self._cells) - self._offset_of_current),
                        program.assertion_ctx)
            except OffEdgeOfTestTapeError:
                # This cell is off the range of what the tape knows about
                pass

        program.assertion_ctx.remove_unused_vars(self._used_variables)

    def loop_level_change(self) -> int:
        return 0

    def span(self) -> Span:
        return self._span

    def ends_assertion_block(self) -> bool:
        return True

    def random_matching_tape(self, ctx: AssertionCtx) -> Tape:
        for var in self._used_variables:
            if var not in ctx.bound_vars:
                ctx.bound_vars[var] = ctx.random_biased_byte()
        data: List[int] = []
        for cell in self._cells:
            data.append(cell.random_matching(ctx))
        tape = Tape(self._offset_of_current, data, False, True)
        self.apply_bounds_to_tape(tape)
        return tape

class StartTapeAssertion(TapeAssertion):
    def __init__(self, span: Span):
        self._span = span

    def __str__(self):
        return '= 0...'

    def run(self, program: Program):
        program.assertion_ctx.remove_unused_vars(set())
        program.tape.set_assertion_bounds(0, None)

    def random_matching_tape(self, ctx: AssertionCtx) -> Tape:
        return Tape(0, [], True, False)
