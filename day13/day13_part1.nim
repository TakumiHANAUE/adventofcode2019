import strutils

import opecode

type
    TileID = enum
        EMPTY, WALL, BLOCK, PADDLE, BALL

type
    Tile = tuple[x, y: int, id: seq[TileID]]

# index
const X = 0
const Y = 1
const ID = 2

let fileName: string = "./day13input.txt"

var inputFile: File
var program: string
var programSeq: seq[int]
let input: int = 0

# read program
inputFile = open(fileName, fmRead)
program = inputFile.readAll()
for code in program.split(","):
    programSeq.add(parseInt(code))

# run program
var i: int = 0
var pointerShift: int = 0
var outputSeq: seq[int]
var outputData: seq[Tile]
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
        var output: int = opeCode4(i, programSeq)
        outputSeq.add(output)
        if outputSeq.len() == 3:
            var isfound: bool = false
            # add tile id into position already exists
            for i in 0..outputData.high:
                if outputSeq[X] == outputData[i].x and outputSeq[Y] == outputData[i].y:
                    isfound = true
                    outputData[i].id.add(TileID(outputSeq[ID]))
            # add a new tile data
            if isfound == false:
                var x: int = outputSeq[X]
                var y: int = outputSeq[Y]
                var id: seq[TileID] = @[TileID(outputSeq[ID])]
                outputData.add( (x, y, id) )
            outputSeq = @[]
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
echo "Program halts."

var numOfBlock: int = 0
for data in outputData.items:
    if data.id[data.id.high] == BLOCK:
        inc(numOfBlock)

echo "Number of Block : ", numOfBlock