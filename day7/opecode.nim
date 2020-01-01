import strutils
import algorithm

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

proc getValue(pos: int, program: seq[int], argNumber: int): int =
    let arg: int = program[pos + argNumber]
    case getParameterMode(program[pos], argNumber)
    of 0:
        result = program[arg]
    of 1:
        result = arg
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
        let arg3: int = program[pos + 3]
        program[arg3] = value1 + value2
    of 1:
        # immediate mode
        echo "opeCode1 arg3: immediate mode"
    else:
        echo "Invalid parameter mode"

proc opeCode2*(pos: int, program: var seq[int]): void =
    #echo "c1 ", program[pos], " ", program[pos + 1], " ", program[pos + 2], " ", program[pos + 3]
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)

    case getParameterMode(program[pos], 3)
    of 0:
        # position mode
        let arg3: int = program[pos + 3]
        program[arg3] = value1 * value2
    of 1:
        # immediate mode
        echo "opeCode2 arg3: immediate mode"
    else:
        echo "Invalid parameter mode"

proc opeCode3*(pos: int, program: var seq[int], input: int): void =
    let arg1: int = program[pos + 1]
    #echo "c3 ", program[pos], " ", arg1
    case getParameterMode(program[pos], 1)
    of 0:
        # position mode
        program[arg1] = input
    of 1:
        # immediate mode
        echo "opeCode3 arg1: immediate mode"
    else:
        echo "Invalid parameter mode"

proc opeCode4*(pos: int, program: var seq[int]): int =
    let arg1: int = program[pos + 1]
    #echo "c4 ", program[pos], " ", arg1
    case getParameterMode(program[pos], 1)
    of 0:
        # position mode
        result = program[arg1]
        #echo "output: ", result
    of 1:
        # immediate mode
        result = arg1
        #echo "output: ", result, " (immediate mode)"
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
    let arg3: int = program[pos + 3]
    if ( value1 < value2 ):
        program[arg3] = 1
    else:
        program[arg3] = 0

proc opeCode8*(pos: int, program: var seq[int]): void =
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)
    let arg3: int = program[pos + 3]
    if ( value1 == value2 ):
        program[arg3] = 1
    else:
        program[arg3] = 0