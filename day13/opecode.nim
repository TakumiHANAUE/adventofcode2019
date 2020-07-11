import strutils
import algorithm

var relativeBase: int = 0

proc getInstCode*(code: int): int =
    # change code to 5 digits code
    var opecode: string = align($code, 5, '0')
    # delete mode parameters. remain only instruction code
    delete(opecode, 0, 2)
    return parseInt(opecode)

proc getParameterMode(opecode, argNumber: int ): int =
    var modeParams: string = align($opecode, 5, '0')
    delete(modeParams, 3, 4)
    reverse(modeParams)
    result = parseInt($modeParams[(argNumber-1)])
    #echo " parameter mode ", result
    # result = 0: Position mode
    # result = 1: Immediate mode
    # result = 2: Relative mode

proc extendProgram(pos: int, program: var seq[int]): void =
    # program の len を見て、領域外アクセスになる場合は拡張する（値は0）
    var length_diff: int = pos - program.len + 1
    if length_diff > 0:
        program.setLen( cast[Natural](program.len + length_diff) )

proc getValue(pos: int, program: var seq[int], argNumber: int): int =
    extendProgram(pos + argNumber, program)
    let arg: int = program[pos + argNumber]
    case getParameterMode(program[pos], argNumber)
    of 0:
        extendProgram(arg, program)
        result = program[arg]
    of 1:
        result = arg
    of 2:
        extendProgram(arg + relativeBase, program)
        result = program[arg + relativeBase]
    else:
        echo "Invalid mode type"
    #echo " value", argNumber, " = ", result

proc opeCode1*(pos: int, program: var seq[int]): void =
    #echo "c1 ", program[pos], " ", program[pos + 1], " ", program[pos + 2], " ", program[pos + 3]
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)
    
    case getParameterMode(program[pos], 3)
    of 0:
        # position mode
        extendProgram(pos + 3, program)
        let arg3: int = program[pos + 3]
        extendProgram(arg3, program)
        program[arg3] = value1 + value2
    of 1:
        # immediate mode
        echo "opeCode1 arg3: immediate mode"
    of 2:
        # relative mode
        extendProgram(pos + 3, program)
        let arg3: int = program[pos + 3]
        extendProgram(arg3 + relativeBase, program)
        program[arg3 + relativeBase] = value1 + value2
    else:
        echo "Invalid parameter mode"

proc opeCode2*(pos: int, program: var seq[int]): void =
    #echo "c1 ", program[pos], " ", program[pos + 1], " ", program[pos + 2], " ", program[pos + 3]
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)

    case getParameterMode(program[pos], 3)
    of 0:
        # position mode
        extendProgram(pos + 3, program)
        let arg3: int = program[pos + 3]
        extendProgram(arg3, program)
        program[arg3] = value1 * value2
    of 1:
        # immediate mode
        echo "opeCode2 arg3: immediate mode"
    of 2:
        # relative mode
        extendProgram(pos + 3, program)
        let arg3: int = program[pos + 3]
        extendProgram(arg3 + relativeBase, program)
        program[arg3 + relativeBase] = value1 * value2
    else:
        echo "Invalid parameter mode"

proc opeCode3*(pos: int, program: var seq[int], input: int): void =
    let arg1: int = program[pos + 1]
    #echo "input: ", input
    #echo "c3 ", program[pos], " ", arg1
    case getParameterMode(program[pos], 1)
    of 0:
        # position mode
        extendProgram(arg1, program)
        program[arg1] = input
    of 1:
        # immediate mode
        echo "opeCode3 arg1: immediate mode"
    of 2:
        # relative mode
        extendProgram(arg1 + relativeBase, program)
        program[arg1 + relativeBase] = input
    else:
        echo "Invalid parameter mode"

proc opeCode4*(pos: int, program: var seq[int]): int =
    let arg1: int = program[pos + 1]
    #echo "c4 ", program[pos], " ", arg1
    case getParameterMode(program[pos], 1)
    of 0:
        # position mode
        extendProgram(arg1, program)
        result = program[arg1]
        #echo "output: ", result
    of 1:
        # immediate mode
        result = arg1
        #echo "output: ", result, " (immediate mode)"
    of 2:
        # relative mode
        extendProgram(arg1 + relativeBase, program)
        result = program[arg1 + relativeBase]
    else:
        echo "Invalid parameter mode"

proc opeCode5*(pos: int, program: var seq[int], pointerShift: var int): void =
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)
    if ( value1 != 0 ):
        pointerShift = value2 - pos
    else:
        pointerShift = 3

proc opeCode6*(pos: int, program: var seq[int], pointerShift: var int): void =
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)
    if ( value1 == 0 ):
        pointerShift = value2 - pos
    else:
        pointerShift = 3

proc opeCode7*(pos: int, program: var seq[int]): void =
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)

    var arg3: int = 0
    case getParameterMode(program[pos], 3)
    of 0:
        # position mode
        extendProgram(pos + 3, program)
        arg3 = program[pos + 3]
    of 1:
        # immediate mode
        echo "opeCode7 arg3: immediate mode"
    of 2:
        # relative mode
        extendProgram(pos + 3, program)
        arg3 = program[pos + 3] + relativeBase
    else:
        echo "Invalid parameter mode"
    
    extendProgram(arg3, program)
    if ( value1 < value2 ):
        program[arg3] = 1
    else:
        program[arg3] = 0

proc opeCode8*(pos: int, program: var seq[int]): void =
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)

    var arg3: int = 0
    case getParameterMode(program[pos], 3)
    of 0:
        # position mode
        extendProgram(pos + 3, program)
        arg3 = program[pos + 3]
    of 1:
        # immediate mode
        echo "opeCode8 arg3: immediate mode"
    of 2:
        # relative mode
        extendProgram(pos + 3, program)
        arg3 = program[pos + 3] + relativeBase
    else:
        echo "Invalid parameter mode"
    
    extendProgram(arg3, program)
    if ( value1 == value2 ):
        program[arg3] = 1
    else:
        program[arg3] = 0

proc opeCode9*(pos: int, program: var seq[int]): void =
    var value1: int = getValue(pos, program, 1)
    relativeBase = relativeBase + value1
    # echo "relativeBase to ", relativeBase