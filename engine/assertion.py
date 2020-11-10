from instruction import Instruction
from program import Program
from tape import Tape
from assertion_ctx import AssertionCtx
from errors import TestError
from span import Span

from typing import Sequence, Optional, List, Set

class AssertionFailedError(TestError):
    def __init__(self, state, actual: Optional[Tape], message: Optional[str], ctx: AssertionCtx):
        msg = '  Failed: ' + str(state)
        if actual:
            msg += '\n  Actual:   ' + str(actual)
        if ctx.bound_vars:
            msg += '\n  ' + repr(ctx.bound_vars)
        if message:
            msg += '\n  ' + message
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
        return ctx.random_byte()

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
        for i in range(256):
            v = ctx.random_byte()
            if not self._inner.matches(ctx, v):
                return v
        for i in range(256):
            if not self._inner.matches(ctx, i):
                return i
        raise TestError('Literally nothing matches ' + str(self))

class TapeAssertion(Instruction):
    def __init__(self, cells: Sequence[Matcher], offset_of_current: int, span: Span):
        self._cells = cells
        self._offset_of_current = offset_of_current
        self._span = span
        self._used_variables: Set[str] = set()
        for cell in cells:
            used = cell.used_variables()
            if used is not None:
                self._used_variables = self._used_variables.union(used)

    def __str__(self):
        result = '= '
        for i, cell in enumerate(self._cells):
            if i:
                result += ' '
            if i == self._offset_of_current:
                result += '`'
            result += str(cell)
        return result

    def run(self, program: Program):
        program.real_ops += 1
        if program.tape.get_position() < self._offset_of_current:
            raise AssertionFailedError(self, None, 'too far left', program.assertion_ctx)
        actual = [program.tape.get_value(i - self._offset_of_current) for i in range(len(self._cells))]
        for i, cell in enumerate(self._cells):
            cell.bind(program.assertion_ctx, actual[i])
        for i, cell in enumerate(self._cells):
            program.real_ops += 1
            if not cell.matches(program.assertion_ctx, actual[i]):
                actual_tape = Tape(self._offset_of_current, actual)
                raise AssertionFailedError(self, actual_tape, None, program.assertion_ctx)
        program.assertion_ctx.remove_unused_vars(self._used_variables)

    def loop_level_change(self) -> int:
        return 0

    def span(self) -> Span:
        return self._span

    def random_matching_tape(self, ctx: AssertionCtx) -> Tape:
        for var in self._used_variables:
            if var not in ctx.bound_vars:
                ctx.bound_vars[var] = ctx.random_byte()
        data: List[int] = []
        for cell in self._cells:
            data.append(cell.random_matching(ctx))
        return Tape(self._offset_of_current, data)

class TestInput(Instruction):
    def __init__(self, matchers: Sequence[Matcher], span: Span):
        self._matchers = matchers
        self._span = span

    def __str__(self):
        return '$ ' + ' '.join(str(m) for m in self._matchers)

    def run(self, program: Program):
        program.real_ops += 1
        values: List[int] = []
        for m in self._matchers:
            values.append(m.random_matching(program.assertion_ctx))
        program.real_ops += len(values)
        program.io.queue_input(values)

    def loop_level_change(self) -> int:
        return 0

    def span(self) -> Span:
        return self._span
