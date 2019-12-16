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

proc getInputProgram(): seq[int] =
    var inputFile: File
    var program: string
    var programSeq: seq[int]

    # store input intcode program
    inputFile = open("./day2input.txt", fmRead)
    program = inputFile.readAll()
    for code in program.split(","):
        programSeq.add(parseInt(code))
    
    return programSeq
    
proc runProgram(program: seq[int]): int =
    var nextPointer: int = 4
    var instPointer: int = 0
    var programSeq: seq[int] = program
    while programSeq[instPointer] != 99:
        case programSeq[instPointer]
        of 1:
            opeCode1(instPointer, programSeq)
        of 2:
            opeCode2(instPointer, programSeq)
        else:
            echo "ERR: Invalid opecode ", instPointer
            break
        
        inc(instPointer, nextPointer)
    return programSeq[0]

#############################

let expectedOutput: int = 19690720
var output: int = 0
var answer: int = 0
var noun: int = 0
var verb: int = 0

for n in 0..99:
    for v in 0..99:
        # get input program
        var programSeq: seq[int]
        programSeq = getInputProgram()
        
        # modify program before running
        programSeq[1] = n
        programSeq[2] = v

        # run program
        output = runProgram(programSeq)

        if ( output == expectedOutput ):
            noun = n
            verb = v
            answer = 100 * n + v
            break
    if ( output == expectedOutput ):
        break

echo "noun: ", noun, " verb: ", verb
echo "Answer: ", answer
