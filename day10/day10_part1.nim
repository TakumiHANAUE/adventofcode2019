import system
import math
import sequtils

type
    OrthantOder = enum
        ONE = 1, TWO, THREE, FOUR

type
    Position = tuple
        x: int
        y: int
        isAsteroid: bool

type
    RelativePosition = tuple
        x: int
        y: int
        orthant: OrthantOder

proc getOrthantOrder(oriX, oriY, refX, refY: int): OrthantOder =
    var xDiff: int = 0
    var yDiff: int = 0
    var order: OrthantOder = ONE
    xDiff = refX - oriX
    yDiff = refY - oriY
    if xDiff >= 0 and yDiff >= 0:
        order = ONE
    elif xDiff < 0 and yDiff >= 0:
        order = TWO
    elif xDiff < 0 and yDiff < 0:
        order = THREE
    else:
        order = FOUR
    return order

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
    var relativePosMap: seq[RelativePosition]
    for asteroid in asteroidMap:
        var xDiff: int = 0
        var yDiff: int = 0
        var order: OrthantOder = ONE
        xDiff = asteroid.x - stationCandidate.x
        yDiff = asteroid.y - stationCandidate.y
        order = getOrthantOrder(stationCandidate.x, stationCandidate.y, asteroid.x, asteroid.y)
        relativePosMap.add( (x: xDiff, y: yDiff, orthant: order) )
    # make asteroids map that can be detected
    var detectAsteroidMap: seq[RelativePosition]
    var tmpAsteroidMap: seq[RelativePosition]
    for relativePos in relativePosMap:
        if relativePos.x != 0 and relativePos.y != 0:
            var divisor: int = gcd(relativePos.x, relativePos.y)
            tmpAsteroidMap.add( (x: (relativePos.x div divisor), y: (relativePos.y div divisor), orthant: relativePos.orthant) )
        elif relativePos.x == 0 and relativePos.y != 0:
            tmpAsteroidMap.add( (x: 0, y: 1, orthant: relativePos.orthant) )
        elif relativePos.x != 0 and relativePos.y == 0:
            tmpAsteroidMap.add( (x: 1, y: 0, orthant: relativePos.orthant) )
    detectAsteroidMap = deduplicate(tmpAsteroidMap)
    # Best location for a new station
    if detectAsteroidMap.len > bestLocation.asteroidsNum:
        bestLocation = (x: stationCandidate.x, y: stationCandidate.y, asteroidsNum: detectAsteroidMap.len)

echo bestLocation
