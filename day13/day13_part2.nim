import strutils
import opecode

# decided maximum position of X/Y from part1 output
const XMAX = 44
const YMAX = 25
# index
const X = 0
const Y = 1
const ID = 2

type
    TileID = enum
        EMPTY, WALL, BLOCK, PADDLE, BALL
    
    StickPosition = enum
        LEFT = -1, NEUTRAL, RIGHT

    Row = array[0..XMAX, TileID]
    Screen = array[0..YMAX, Row]

let fileName: string = "./day13input.txt"

############

proc convertTileID2Str(id: TileID): string =
    var s: string
    case id
    of WALL:
        s = "W"
    of BLOCK:
        s = "B"
    of PADDLE:
        s = "^"
    of BALL:
        s = "o"
    else:
        s = " "
    return s

proc decideStickPosition(ballPosBefore, ballPos, paddlePos: tuple[x, y: int]): StickPosition =
    # The paddle just chases the ball
    var pos: StickPosition = NEUTRAL
    if (ballPos.x - ballPosBefore.x) > 0:
        if ballPos.x > paddlePos.x:
            pos = RIGHT
    elif (ballPos.x - ballPosBefore.x) < 0:
        if ballPos.x < paddlePos.x:
            pos = LEFT
    return pos

############

var inputFile: File
var program: string
var programSeq: seq[int]

var ballPosision: tuple[x, y: int] = (0, 0)
var ballPosisionBefore: tuple[x, y: int] = (0, 0)
var paddlePosition: tuple[x, y: int] = (0, 0)

# read program
inputFile = open(fileName, fmRead)
program = inputFile.readAll()
for code in program.split(","):
    programSeq.add(parseInt(code))

# set the value 2 at memory 0 to play for free
programSeq[0] = 2

# run program
var i: int = 0
var pointerShift: int = 0
var outputSeq: seq[int]
var screen: Screen
var score: int = 0
while getInstCode(programSeq[i]) != 99:
    case getInstCode(programSeq[i])
    of 1:
        opeCode1(i, programSeq)
        pointerShift = 4
    of 2:
        opeCode2(i, programSeq)
        pointerShift = 4
    of 3:
        # show screen just before input
        for y in 0..YMAX:
            for x in 0..XMAX:
                stdout.write convertTileID2Str(screen[y][x])
                if screen[y][x] == BALL:
                    ballPosisionBefore = ballPosision
                    ballPosision = (x, y)
                elif screen[y][x] == PADDLE:
                    paddlePosition = (x, y)
            echo ""
        echo "<SCORE: ", score, ">"
        var stickPos = decideStickPosition(ballPosisionBefore, ballPosision, paddlePosition)
        opeCode3(i, programSeq, int(stickPos))
        pointerShift = 2
    of 4:
        var output: int = opeCode4(i, programSeq)
        outputSeq.add(output)
        if outputSeq.len() == 3:
            var y: int = outputSeq[Y]
            var x: int = outputSeq[X]
            var value: int = outputSeq[ID]
            if x == -1 and y == 0:
                score = value
            else:
                screen[y][x] = TileID(value)
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

# show last screen
for y in 0..YMAX:
    for x in 0..XMAX:
        stdout.write convertTileID2Str(screen[y][x])
    echo ""
echo "<SCORE: ", score, ">"
echo "Program halts."

