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
import subprocess
from shutil import which

class TestIo(Io):
    def push_output(self, value: int):
        pass

    def pull_input(self) -> int:
        return ord('a')

    def time_waiting_for_input(self) -> float:
        return 0.0

def run_test_code(self, source_path: str, expect_fail: bool):
    args = Args()
    self.init_args(args)
    args.source_path = source_path
    args.expect_fail = expect_fail
    io = TestIo()
    run(args, io)

def engine_path() -> str:
    return os.path.dirname(os.path.realpath(__file__))

def scan_test_files() -> List[Tuple[str, str]]:
    test_dir = os.path.join(engine_path(), 'tests/')
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
class OptimizedIntegrationTests(TestCase):
    def init_args(self, args: Args):
        args.prop_tests = False
        args.optimize = True

@construct_test_class
class OptimizedPropertyTests(TestCase):
    def init_args(self, args: Args):
        args.prop_tests = True
        args.optimize = True

@construct_test_class
class UnoptimizedIntegrationTests(TestCase):
    def init_args(self, args: Args):
        args.prop_tests = False
        args.optimize = False

@construct_test_class
class UnoptimizedPropertyTests(TestCase):
    def init_args(self, args: Args):
        args.prop_tests = True
        args.optimize = False

class EngineTypesTest(TestCase):
    def test_engine_types(self):
        mypy = which('mypy')
        assert mypy is not None, 'Could not check types, mypy required'
        engine = os.path.relpath(engine_path())
        result = subprocess.run([mypy, engine], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        if result.returncode != 0:
            raise RuntimeError('`$ mypy ' + engine + '` failed:\n' + result.stdout)

if __name__ == '__main__':
    unittest.main()
