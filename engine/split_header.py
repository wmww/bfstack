from instruction import Instruction
from op import Op

from typing import Tuple, List

def split_header(code: List[Instruction]) -> Tuple[List[Instruction], List[Instruction]]:
    '''A file has a header comment if the first op is a loop start. This is considered a comment
    because the loop will never run. It ends with that initial loop. This function splits the
    header from the rest of the code'''
    loop_depth = 0
    for i, instr in enumerate(code):
        if isinstance(instr, Op):
            if loop_depth > 0 or instr.loop_level_change() > 0:
                loop_depth += instr.loop_level_change()
                if loop_depth <= 0:
                    return code[:i], code[i:]
            else:
                # instr is a brainfuck op
                # loop depth is <= 0 so we are not in a header comment yet
                # instr.loop_level_change() <= 0, so this is not the start of a header comment
                # therefore this file does not not have a header comment
                break
    return [], code
