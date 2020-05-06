import system
import math
import sequtils
import algorithm

type
    Position = tuple
        x: int
        y: int
        isAsteroid: bool

type
    RelativePosition = tuple
        x: int
        y: int
        slopeVector: tuple[x, y: int]

proc getSlope(x, y: int): tuple[x, y: int] =
    var slope: tuple[x, y: int]
    if x != 0 and y != 0:
        let divisor1: int = gcd(x, y)
        slope = (x: (x div divisor1), y: (y div divisor1) )
    elif x == 0 and y != 0:
        if y > 0:
            slope = (x: 0, y: 1 )
        else:
            slope = (x: 0, y: -1 )
    elif x != 0 and y == 0:
        if x > 0:
            slope = (x: 1, y: 0 )
        else:
            slope = (x: -1, y: 0 )
    else:
        slope = (x: 0, y: 0 )
    return slope

proc getSlopeVector(oriX, oriY, refX, refY: int): tuple[x, y: int] =
    var xDiff: int = 0
    var yDiff: int = 0
    xDiff = refX - oriX
    yDiff = refY - oriY
    return getSlope(xDiff, yDiff)

proc getRelativePositionMap(oriX, oriY: int, absolutePositionMap: seq[Position]): seq[RelativePosition] =
    var relativePositionMap: seq[RelativePosition]
    for asteroid in absolutePositionMap:
        var xDiff: int = 0
        var yDiff: int = 0
        var vector: tuple[x, y: int]
        xDiff = asteroid.x - oriX
        yDiff = asteroid.y - oriY
        if xDiff != 0 or yDiff != 0:
            vector = getSlopeVector(oriX, oriY, asteroid.x, asteroid.y)
            relativePositionMap.add( (x: xDiff, y: yDiff, slopeVector: vector) )
    return relativePositionMap

proc getRadian(x, y: int): float32 =
    var radian = arctan2(float(y), float(x))
    # arctan2 output is between -PI to PI
    if y < 0:
        radian += (2 * PI)
    return radian

proc asteroidCmp(asteroid1, asteroid2: RelativePosition): int =
    const AST1_IS_LOWER: int = -1
    const AST1_IS_HIGHER: int = 1
    var cmpResult: int = 0
    # exchange x and y value because radian starts from negative y direction
    let ast1: RelativePosition = (-(asteroid1.y), asteroid1.x, asteroid1.slopeVector)
    let ast2: RelativePosition = (-(asteroid2.y), asteroid2.x, asteroid2.slopeVector)

    let ast1Slope: tuple[x, y: int] = getSlope(ast1.x, ast1.y)
    let ast2Slope: tuple[x, y: int] = getSlope(ast2.x, ast2.y)
    if ast1Slope != ast2Slope:
        let ast1Radian = getRadian(ast1Slope.x, ast1Slope.y)
        let ast2Radian = getRadian(ast2Slope.x, ast2Slope.y)
        if ast1Radian < ast2Radian:
            cmpResult = AST1_IS_LOWER
        elif ast1Radian > ast2Radian:
            cmpResult = AST1_IS_HIGHER
    else:
        let ast1DistanceSqr = (ast1.x ^ 2) + (ast1.y ^ 2)
        let ast2DistanceSqr = (ast2.x ^ 2) + (ast2.y ^ 2)
        if ast1DistanceSqr < ast2DistanceSqr:
            cmpResult = AST1_IS_LOWER
        elif ast1DistanceSqr > ast2DistanceSqr:
            cmpResult = AST1_IS_HIGHER
    return cmpResult

############################

var inputFile: File
var asteroidMap: seq[Position]

# read input file
# make asteroid map
inputFile = open("./day10input.txt", fmRead)
var ypos: int = 0
for line in inputFile.lines:
    for xpos in 0..(line.len - 1):
        if line[xpos] == '#':
            var asteroid: Position = (x: xpos, y: ypos, isAsteroid: true)
            asteroidMap.add(asteroid)
    inc(ypos)


# search best location for a new station
var bestLocation: tuple[x, y, asteroidsNum: int] = (0, 0, 0)
for stationCandidate in asteroidMap:
    # make relative position map
    var relativeAsteroidPosMap: seq[RelativePosition]
    relativeAsteroidPosMap = getRelativePositionMap(stationCandidate.x, stationCandidate.y, asteroidMap)
    # make asteroids map that can be detected
    var detectedVectorSeq: seq[tuple[x, y: int]]
    var slopeVectorSeq: seq[tuple[x, y: int]]
    for relativePos in relativeAsteroidPosMap:
        slopeVectorSeq.add(relativePos.slopeVector)
    detectedVectorSeq = deduplicate(slopeVectorSeq)
    # Best location for a new station
    if detectedVectorSeq.len > bestLocation.asteroidsNum:
        bestLocation = (x: stationCandidate.x, y: stationCandidate.y, asteroidsNum: detectedVectorSeq.len)

# make relative position map for best location
var relativePositionMap: seq[RelativePosition]
relativePositionMap = getRelativePositionMap(bestLocation.x, bestLocation.y, asteroidMap)
# sorted relative position map by radian and distance from station
var sortedRelativePositionMap: seq[RelativePosition]
sortedRelativePositionMap = sorted(relativePositionMap, asteroidCmp, SortOrder.Ascending)

# make vaporizing order list
var vaporizingOrderSeq: seq[RelativePosition]
while vaporizingOrderSeq.len != sortedRelativePositionMap.len:
    var slopevec: tuple[x, y: int] = (0, 0)
    for i in 0..(sortedRelativePositionMap.len - 1):
        # not moved to vaporizingOrderSeq yet
        if sortedRelativePositionMap[i] != (0, 0, (0, 0)):
            # cannot vaporize the asteroid at the same direction in a row
            if sortedRelativePositionMap[i].slopeVector != slopevec:
                vaporizingOrderSeq.add(sortedRelativePositionMap[i])
                slopevec = sortedRelativePositionMap[i].slopeVector
                # clear i-th asteroid because it moves to vaporizingOrderSeq
                sortedRelativePositionMap[i] = (x: 0, y: 0, slopeVector: (0, 0))

# the 200th asteroid to be vaporized
echo "(x, y) = (", vaporizingOrderSeq[199].x + bestLocation.x, ", ", vaporizingOrderSeq[199].y + bestLocation.y, ")"

