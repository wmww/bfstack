import argparse
from typing import List, Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from span import Span

default_test_iters = 48
default_test_endless_loop_threshold = 10000

class Args:
    def __init__(self) -> None:
        self.source_path: Optional[str] = None
        self._snippets = True
        self._assertions = True
        self.show_info = True
        self.optimize = True
        self.prop_tests = False
        self.shallow = False
        self.test_iterations = default_test_iters
        self.test_endless_loop_threshold = default_test_endless_loop_threshold
        self.expect_fail = False

    def assertions_enabled_for(self, span: 'Span') -> bool:
        if self._assertions:
            if self.shallow and span.source_file().is_used():
                return False
            else:
                return True
        else:
            return False

    def snippets_enabled_for(self, span: 'Span') -> bool:
        if self._snippets:
            if self.shallow and span.source_file().is_used():
                return False
            else:
                return True
        else:
            return False

    def snippets_enabled_anywhere(self) -> bool:
        return self._snippets

    def parse(self, argv: List[str]):
        parser = argparse.ArgumentParser(description='Run and/or test a brainfuck program')
        parser.add_argument('source_file', type=str, help='brainfuck source code file to load')
        parser.add_argument(
            '-r', '--run-only', action='store_true',
            help='just run Brainfuck code without any syntax extensions (equivalent to -SA)')
        parser.add_argument(
            '-t', '--test', action='store_true',
            help='run each assertion block independently with random values')
        parser.add_argument(
            '-i', '--info', action='store_true',
            help='show stats and other debugging info')
        parser.add_argument(
            '-S', '--no-snippets', action='store_true',
            help='disable tagged snippet checking, see readme for details. ' +
                 'No runtime perf cost after initial parse')
        parser.add_argument(
            '-A', '--no-assertions', action='store_true',
            help='disable assertion checking, see readme for details. May have runtime perf cost')
        parser.add_argument(
            '-0', '--no-optimize', action='store_true',
            help='don\'t apply any optimizations')
        parser.add_argument(
            '--iterations', type=int,
            help='if running tests, number of iterations to run. Default is ' + str(default_test_iters))
        parser.add_argument(
            '--shallow', action='store_true',
            help='do not check snippets and run tests from `use`d files')
        parser.add_argument(
            '-c', '--color', action='store_true',
            help='force enable terminal colors')
        parser.add_argument(
            '-C', '--no-color', action='store_true',
            help='force disable terminal colors')
        result = parser.parse_args(argv)
        self.source_path = result.source_file
        self._snippets = not (result.no_snippets or result.run_only)
        self._assertions = not (result.no_assertions or result.run_only)
        self.show_info = result.info
        self.optimize = not result.no_optimize
        self.prop_tests = result.test
        self.shallow = result.shallow
        if result.iterations is not None:
            self.test_iterations = result.iterations

        import colors
        if result.color:
            colors.use_color = True
        if result.no_color:
            colors.use_color = False

        if result.iterations is not None and not result.test:
            raise RuntimeError('iterations can only be specified when running tests')

        if self.prop_tests and not self._assertions:
            raise RuntimeError('assertions must be enabled in order to run tests')
