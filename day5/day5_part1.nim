import system
import strutils
import algorithm


proc getInstCode(code: int): int =
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

proc opeCode1(pos: int, program: var seq[int]): void =
    #echo "c1 ", program[pos], " ", program[pos + 1], " ", program[pos + 2], " ", program[pos + 3]
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)
    
    case getParameterMode(program[pos], 3)
    of 0:
        # position mode
        #echo " ", value1, " ", value2
        let arg3: int = program[pos + 3]
        program[arg3] = value1 + value2
    of 1:
        # immediate mode
        echo "opeCode1 arg3: immediate mode"
    else:
        echo "Invalid parameter mode"

proc opeCode2(pos: int, program: var seq[int]): void =
    #echo "c1 ", program[pos], " ", program[pos + 1], " ", program[pos + 2], " ", program[pos + 3]
    var value1: int = getValue(pos, program, 1)
    var value2: int = getValue(pos, program, 2)

    case getParameterMode(program[pos], 3)
    of 0:
        # position mode
        #echo " ", value1, " ", value2
        let arg3: int = program[pos + 3]
        program[arg3] = value1 * value2
    of 1:
        # immediate mode
        echo "opeCode2 arg3: immediate mode"
    else:
        echo "Invalid parameter mode"

proc opeCode3(pos: int, program: var seq[int]): void =
    let input: int = 1
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

proc opeCode4(pos: int, program: var seq[int]): void =
    let arg1: int = program[pos + 1]
    #echo "c4 ", program[pos], " ", arg1
    case getParameterMode(program[pos], 1)
    of 0:
        # position mode
        echo "output: ", program[arg1]
    of 1:
        # immediate mode
        echo "output: ", arg1, " (immediate mode)"
    else:
        echo "Invalid parameter mode"

var inputFile: File
var program: string
var programSeq: seq[int]

# store input intcode program
inputFile = open("./day5input.txt", fmRead)
program = inputFile.readAll()
for code in program.split(","):
    programSeq.add(parseInt(code))

# run program
var i: int = 0
var pointerShift: int = 4
while getInstCode(programSeq[i]) != 99:
    case getInstCode(programSeq[i])
    of 1:
        opeCode1(i, programSeq)
        pointerShift = 4
    of 2:
        opeCode2(i, programSeq)
        pointerShift = 4
    of 3:
        opeCode3(i, programSeq)
        pointerShift = 2
    of 4:
        opeCode4(i, programSeq)
        pointerShift = 2
    else:
        echo "ERR: Invalid opecode ", i
        break
    # echo i, " ", programSeq
    inc(i, pointerShift)

echo "Program halts."