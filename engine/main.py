#!/usr/bin/python3

from args import Args
from errors import ProgramError, ParseError, FileLoadingError
from user_io import UserIo
from run import run
from colors import make_color, Color

import sys
import logging

logger = logging.getLogger(__name__)

def main() -> None:
    args = Args()
    try:
        args.parse(sys.argv[1:]) # strip off the first argument (program name)
    except RuntimeError as e:
        logger.error('Error: ' + str(e))
        exit(1)
    if args.show_info:
        logging.basicConfig(level=logging.INFO)
    success = False
    try:
        io = UserIo()
        run(args, io)
        success = True
    except (FileLoadingError, ParseError, ProgramError) as e:
        logger.error(e)
    if not success:
        exit(1)

if __name__ == '__main__':
    main();
