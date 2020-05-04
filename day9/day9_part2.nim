import system
import strutils
import opecode

var inputFile: File
var program: string
var programSeq: seq[int]
let input: int = 2 # 2 : value for boost mode

# store input intcode program
inputFile = open("./day9input.txt", fmRead)
program = inputFile.readAll()
for code in program.split(","):
    programSeq.add(parseInt(code))

# run program
var i: int = 0
var pointerShift: int = 0
while getInstCode(programSeq[i]) != 99:
    case getInstCode(programSeq[i])
    of 1:
        opeCode1(i, programSeq)
        pointerShift = 4
    of 2:
        opeCode2(i, programSeq)
        pointerShift = 4
    of 3:
        opeCode3(i, programSeq, input)
        pointerShift = 2
    of 4:
        # echo i, " ", programSeq
        var output: int = opeCode4(i, programSeq)
        echo "output : ", output
        # echo i, " ", programSeq
        pointerShift = 2
    of 5:
        opeCode5(i, programSeq, pointerShift)
    of 6:
        opeCode6(i, programSeq, pointerShift)
    of 7:
        opeCode7(i, programSeq)
        pointerShift = 4
    of 8:
        opeCode8(i, programSeq)
        pointerShift = 4
    of 9:
        opeCode9(i, programSeq)
        pointerShift = 2
    else:
        echo "ERR: Invalid opecode ", i, " ", programSeq[i]
        break
    inc(i, pointerShift)
# echo i, " ", programSeq
echo "Program halts."