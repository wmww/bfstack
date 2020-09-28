#!/usr/bin/python3

from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse

from typing import List, Tuple
import os
import unittest
from unittest import TestCase, TestSuite, TestResult

input_buffer: List[str] = []

def output_fn(c: str):
    raise RuntimeError('Produced output: ' + c + ', output handling not implemented in tests')

def input_fn() -> str:
    global input_buffer
    raise RuntimeError('Input handling not implemented in tests')

def run_test_code(self, source_path):
    print('Running ' + source_path)
    args = Args()
    args.source_path = source_path
    source_file = SourceFile(args)
    code = parse.source(source_file, args)
    program = Program(Tape(0, []), code, output_fn, input_fn)
    while program.iteration():
        pass

def scan_test_files() -> List[Tuple[str, str]]:
    test_dir = os.path.dirname(os.path.realpath(__file__)) + '/tests/'
    result = []
    for name in os.listdir(test_dir):
        if name.endswith('.bf'):
            result.append((os.path.basename(name), test_dir + name))
    return result

def build_test_runner(source_path):
    def fn(self):
        run_test_code(self, source_path)
    return fn

def get_test_cases() -> List:
    test_files = scan_test_files()
    method_map = {}
    for name, source_path in test_files:
        method_map['test_' + name] = build_test_runner(source_path)
    return [
        type('TestSourceFiles', (TestCase, ), method_map),
    ]

def load_tests(loader, tests, pattern):
    '''Called automatically by unittest.main()'''
    suite = TestSuite()
    for test_class in get_test_cases():
        tests = loader.loadTestsFromTestCase(test_class)
        suite.addTests(tests)
    return suite

if __name__ == '__main__':
    unittest.main()
