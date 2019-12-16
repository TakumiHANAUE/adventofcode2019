import system
import strutils

proc opeCode1(pos: int, program: var seq[int]): void =
    var arg1: int = program[pos + 1]
    var arg2: int = program[pos + 2]
    var arg3: int = program[pos + 3]
    program[arg3] = program[arg1] + program[arg2]

proc opeCode2(pos: int, program: var seq[int]): void =
    var arg1: int = program[pos + 1]
    var arg2: int = program[pos + 2]
    var arg3: int = program[pos + 3]
    program[arg3] = program[arg1] * program[arg2]


var inputFile: File
var program: string
var programSeq: seq[int]

# store input intcode program
inputFile = open("./day2input.txt", fmRead)
program = inputFile.readAll()
for code in program.split(","):
    programSeq.add(parseInt(code))

# modify program before running
programSeq[1] = 12
programSeq[2] = 2

# run program
var i: int = 0
while programSeq[i] != 99:
    case programSeq[i]
    of 1:
        opeCode1(i, programSeq)
    of 2:
        opeCode2(i, programSeq)
    else:
        echo "ERR: Invalid opecode ", i
        break
    # echo i, " ", programSeq
    inc(i, 4)

echo "Program halts."
echo "The value at position 0 is ", programSeq[0], "."