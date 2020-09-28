import argparse
from typing import List

class Args:
    def __init__(self):
        self.source_path = None
        self.assertions = True
        self.show_info = True
        self.optimize = True

    def parse(self, argv: List[str]):
        parser = argparse.ArgumentParser(description='Run and/or test a brainfuck program')
        parser.add_argument('source_file', type=str, help='brainfuck source code file to load')
        parser.add_argument('-a', '--assertions', action='store_true', help='check assertion lines')
        parser.add_argument('-i', '--info', action='store_true', help='show stats and other debugging info')
        parser.add_argument('--no-optimize', action='store_true', help='don\'t run any optimizations')
        result = parser.parse_args(argv)
        self.source_path = result.source_file
        self.assertions = result.assertions
        self.show_info = result.info
        self.optimize = not result.no_optimize
