import argparse
from typing import List

default_test_iters = 10

class Args:
    def __init__(self):
        self.source_path = None
        self.assertions = True
        self.show_info = True
        self.optimize = True
        self.prop_tests = False
        self.test_iterations = default_test_iters

    def parse(self, argv: List[str]):
        parser = argparse.ArgumentParser(description='Run and/or test a brainfuck program')
        parser.add_argument('source_file', type=str, help='brainfuck source code file to load')
        parser.add_argument(
            '-a', '--assertions', action='store_true',
            help='parse and check assertions, see readme for details')
        parser.add_argument(
            '-p', '--property-test', action='store_true',
            help='run each assertion block independently with random values')
        parser.add_argument('-i', '--info', action='store_true', help='show stats and other debugging info')
        parser.add_argument('-0', '--no-optimize', action='store_true', help='don\'t apply any optimizations')
        result = parser.parse_args(argv)
        self.source_path = result.source_file
        self.assertions = result.assertions or result.property_test
        self.show_info = result.info
        self.optimize = not result.no_optimize
        self.prop_tests = result.property_test
