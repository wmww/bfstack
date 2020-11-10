#!/usr/bin/python3

from args import Args
from span import Span
from io_interface import Io
from run import run
from errors import ProgramError, ParseError, TestError

from typing import List, Tuple
import os
import unittest
from unittest import TestCase, TestSuite, TestResult

class TestIo(Io):
    def __init__(self):
        self.queue: List[int] = []

    def push_output(self, value: int):
        pass

    def pull_input(self) -> int:
        if self.queue:
            return self.queue.pop(0)
        else:
            raise TestError('Input requested without test input being queued')

    def queue_input(self, values: List[int]):
        if self.queue:
            raise TestError('Test input given with ' + str(len(self.queue)) + ' unconsumed inputs')
        else:
            self.queue = values

    def time_waiting_for_input(self) -> float:
        return 0.0

def run_test_code(self, source_path, expect_fail):
    args = Args()
    args.source_path = source_path
    args.run_tests = True
    io = TestIo()
    error = None
    try:
        run(args, io)
        if io.queue:
            raise TestError('Program finalized with ' + str(len(io.queue)) + ' unconsumed test inputs')
    except (ProgramError, ParseError) as e:
        error = e
    if error is None:
        if expect_fail:
            self.fail('Test passed unexpectedly, tape: ' + str(tape))
    else:
        if not expect_fail:
            self.fail('Test failed: ' + str(error))

def scan_test_files() -> List[Tuple[str, str]]:
    test_dir = os.path.dirname(os.path.realpath(__file__)) + '/tests/'
    result = []
    for name in os.listdir(test_dir):
        if name.endswith('.bf'):
            result.append((os.path.splitext(name)[0], test_dir + name))
    return result

def build_test_runner(source_path, expect_fail):
    def fn(self):
        run_test_code(self, source_path, expect_fail)
    return fn

def construct_test_class(cls) -> List:
    test_files = scan_test_files()
    for name, source_path in test_files:
        expect_fail = name.endswith('_fails')
        runner = build_test_runner(source_path, expect_fail)
        setattr(cls, 'test_' + name, runner)
    return cls

@construct_test_class
class TestSourceFiles(TestCase):
    pass

if __name__ == '__main__':
    unittest.main()
