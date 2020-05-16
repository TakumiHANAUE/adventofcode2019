import system
import strutils
import logging

import opecode

const OUTPUT_COLOR_INDEX = 0
const OUTPUT_DIRECTION_INDEX = 1
const OUTPUT_VALUE_LEN_MAX = 2

type
    Position = tuple
        x: int
        y: int

type
    Color = enum
        BLACK = 0, WHITE

const START_PANEL_COLOR: Color = WHITE

type
    Panel = tuple
        position: Position
        color: Color

type
    Direction = enum
        X_POSITIVE, X_NEGATIVE, Y_POSITIVE, Y_NEGATIVE

        #                Y_NEGATIVE
        #                |
        # X_NEGATIVE --- + ---> X_POSITIVE
        #                |
        #                v
        #                Y_POSITIVE

type
    TurnDirection = enum
        LEFT90DEG = 0, RIGHT90DEG

type
    PaintingRobot* = ref object of RootObj
        position: Position
        direction: Direction
        paintedPanels: seq[tuple[pos: Position, color: seq[Color]]]
        inputValue: int
        outputValue: seq[int]
        programSeq: seq[int]
        programIndex: int
        isRunning: bool
        logger: ConsoleLogger

method initialize*(robot: PaintingRobot): void {.base.} =
    robot.position = (0, 0)
    robot.direction = Y_POSITIVE
    robot.paintedPanels = @[]
    robot.inputValue = -1
    robot.outputValue = @[]
    robot.programIndex = 0
    robot.isRunning = true
    robot.logger = newConsoleLogger(fmtStr="$levelname: ")
    addHandler(robot.logger)

method readProgram*(robot: PaintingRobot, fileName: string): void {.base.} =
    var inputFile: File
    var program: string
    inputFile = open(fileName, fmRead)
    program = inputFile.readAll()
    for code in program.split(","):
        robot.programSeq.add(parseInt(code))

method scanPanelColor*(robot: PaintingRobot): void {.base.} =
    var panelColor: Color = BLACK
    if robot.paintedPanels.len == 0:
        panelColor = START_PANEL_COLOR
    elif robot.paintedPanels.len != 0:
        for i in 0..robot.paintedPanels.high:
            if robot.paintedPanels[i].pos == robot.position:
                var index: int = robot.paintedPanels[i].color.high
                panelColor = robot.paintedPanels[i].color[index]
                debug("panelColor is ", panelColor)
                break
    robot.inputValue = int(panelColor)

method readColorToPaint(robot: PaintingRobot): Color {.base.} =
    var color: Color = Color(robot.outputValue[OUTPUT_COLOR_INDEX])
    debug("color to paint is ", color)
    return color

method readDirectionToTurn(robot: PaintingRobot): TurnDirection {.base.} =
    var direction: TurnDirection = TurnDirection(robot.outputValue[OUTPUT_DIRECTION_INDEX])
    debug("read direction is ", direction)
    return direction

method move*(robot: PaintingRobot): void {.base.} =
    var nextPos: Position
    var nextDirection: Direction
    var turnDirection: TurnDirection = robot.readDirectionToTurn()
    if robot.direction == X_POSITIVE:
        if turnDirection == LEFT90DEG:
            nextPos = (robot.position.x, robot.position.y - 1)
            nextDirection = Y_NEGATIVE
        elif turnDirection == RIGHT90DEG:
            nextPos = (robot.position.x, robot.position.y + 1)
            nextDirection = Y_POSITIVE
    elif robot.direction == X_NEGATIVE:
        if turnDirection == LEFT90DEG:
            nextPos = (robot.position.x, robot.position.y + 1)
            nextDirection = Y_POSITIVE
        elif turnDirection == RIGHT90DEG:
            nextPos = (robot.position.x, robot.position.y - 1)
            nextDirection = Y_NEGATIVE
    elif robot.direction == Y_NEGATIVE:
        if turnDirection == LEFT90DEG:
            nextPos = (robot.position.x - 1, robot.position.y)
            nextDirection = X_NEGATIVE
        elif turnDirection == RIGHT90DEG:
            nextPos = (robot.position.x + 1, robot.position.y)
            nextDirection = X_POSITIVE
    elif robot.direction == Y_POSITIVE:
        if turnDirection == LEFT90DEG:
            nextPos = (robot.position.x + 1, robot.position.y)
            nextDirection = X_POSITIVE
        elif turnDirection == RIGHT90DEG:
            nextPos = (robot.position.x - 1, robot.position.y)
            nextDirection = X_NEGATIVE
    robot.position = nextPos
    robot.direction = nextDirection
    debug("move to ", robot.position, " : direction ", robot.direction)

method runProgram(robot: PaintingRobot): void {.base.} =
    var pointerShift: int = 0
    robot.outputValue = @[]
    while robot.isRunning == true:
        info("index ", robot.programIndex, " code ", getInstCode(robot.programSeq[robot.programIndex]))
        case getInstCode(robot.programSeq[robot.programIndex])
        of 1:
            opeCode1(robot.programIndex, robot.programSeq)
            pointerShift = 4
        of 2:
            opeCode2(robot.programIndex, robot.programSeq)
            pointerShift = 4
        of 3:
            opeCode3(robot.programIndex, robot.programSeq, robot.inputValue)
            robot.inputValue = -1
            pointerShift = 2
        of 4:
            var output: int = opeCode4(robot.programIndex, robot.programSeq)
            robot.outputValue.add(output)
            debug("output ", robot.outputValue)
            pointerShift = 2
        of 5:
            opeCode5(robot.programIndex, robot.programSeq, pointerShift)
        of 6:
            opeCode6(robot.programIndex, robot.programSeq, pointerShift)
        of 7:
            opeCode7(robot.programIndex, robot.programSeq)
            pointerShift = 4
        of 8:
            opeCode8(robot.programIndex, robot.programSeq)
            pointerShift = 4
        of 9:
            opeCode9(robot.programIndex, robot.programSeq)
            pointerShift = 2
        else:
            echo "ERR: Invalid opecode ", robot.programIndex, " ", robot.programSeq[robot.programIndex]
            break
        inc(robot.programIndex, pointerShift)
        if robot.outputValue.len == OUTPUT_VALUE_LEN_MAX:
            debug("filled outputValue")
            break;
        if getInstCode(robot.programSeq[robot.programIndex]) == 99:
            debug("program finished")
            robot.isRunning = false

method paintPanel*(robot: PaintingRobot): bool {.base.} =
    var ret: bool = false
    # run IntCode program
    robot.runProgram()
    if robot.isRunning == true:
        ret = true
        # read color
        var color: Color = robot.readColorToPaint()
        debug("paint color ", color)
        # painting process
        var match: bool = false
        for i in 0..robot.paintedPanels.high:
            if robot.paintedPanels[i].pos == robot.position:
                robot.paintedPanels[i].color.add(color)
                match = true
        if match == false:
            var colorSeq: seq[Color]
            colorSeq.add(color)
            robot.paintedPanels.add((robot.position, colorSeq))
    return ret

method isRunning*(robot: PaintingRobot): bool {.base.} =
    return robot.isRunning

method outputPaintedPanelNum*(robot: PaintingRobot): void {.base.} =
    echo "Painted ", robot.paintedPanels.len, " panels."

method showRegistrationIdentifier*(robot: PaintingRobot): void {.base.} =
    # gather position and color information for all panels
    var allPaintedPanels: seq[Panel]
    var xCoordinates: seq[int]
    var yCoordinates: seq[int]
    for i in 0..robot.paintedPanels.high:
        var atLastPainted = robot.paintedPanels[i].color.high
        allPaintedPanels.add((robot.paintedPanels[i].pos, robot.paintedPanels[i].color[atLastPainted]))
        xCoordinates.add(robot.paintedPanels[i].pos.x)
        yCoordinates.add(robot.paintedPanels[i].pos.y)
    # # sort panels in order
    # var sortedAllPaintedPanels: seq[Panel]
    # sortedAllPaintedPanels = sorted(allPaintedPanels, panelPositionCmp, SortOrder.Ascending)
    # get min/max value of x/y coordinate
    var minX: int = xCoordinates.min()
    var maxX: int = xCoordinates.max()
    var minY: int = yCoordinates.min()
    var maxY: int = yCoordinates.max()
    # make initial panels to show
    var identifier: seq[seq[Panel]]
    for y in minY..maxY:
        var panelRow: seq[Panel]
        for x in minX..maxX:
            var position: Position = (x, y)
            panelRow.add( (position, BLACK) )
        identifier.add(panelRow)
    # input painted color
    for panel in allPaintedPanels.items:
        let indexX = panel.position.x - minX
        let indexY = panel.position.y - minY
        identifier[indexY][indexX] = panel
    # output Registration Identifier
    for y in 0..identifier.high:
        for x in 0..identifier[0].high:
            var color: Color = identifier[y][x].color
            var printChar: string = ""
            if color == BLACK:
                printChar = " "
            elif color == WHITE:
                printChar = "X"
            stdout.write printChar
        echo ""
