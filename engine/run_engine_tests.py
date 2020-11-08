#!/usr/bin/python3

from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse
from errors import ProgramError, ParseError

from typing import List, Tuple
import os
import unittest
from unittest import TestCase, TestSuite, TestResult

def output_fn(c: str):
    pass

def run_test_code(self, source_path, expect_fail):
    args = Args()
    args.source_path = source_path
    args.run_tests = True
    source_file = SourceFile(args)
    error = None
    try:
        code = parse.source(source_file, args)
        tape = Tape(0, [])
        program = Program(tape, code, output_fn, None)
        while program.iteration():
            pass
        program.finalize()
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
