import system
import strutils
import algorithm

type
    Path = tuple
        direction: char
        distance: int

type
    Point = tuple
        x: int
        y: int

proc parsePath(path: string): Path =
    var pathString = path
    var pathTuple: Path
    pathTuple.direction = pathString[0]
    pathString.delete(0, 0)
    pathTuple.distance = parseInt(pathString)
    return pathTuple

proc getCrossedPoints(path: seq[Path]): seq[Point] =
    var points: seq[Point]
    # add origin(central port)
    points.add((0, 0))
    # add points
    var dx: int = 0
    var dy: int = 0
    for p in path:
        # decide direction
        case p.direction
        of 'R':
            dx = 1
            dy = 0
        of 'L':
            dx = -1
            dy = 0
        of 'U':
            dx = 0
            dy = 1
        of 'D':
            dx = 0
            dy = -1
        else:
            echo "Unknown direction: ", p.direction
            break
        # add points
        var baseIndex: int = points.high
        var baseX: int = points[baseIndex].x
        var baseY: int = points[baseIndex].y
        for i in 1..p.distance:
            points.add((baseX + (dx * i), baseY + (dy * i)))
    return points

proc getIntersectionPoints(points1, points2: seq[Point]): seq[Point] =
    var intersectionPoints: seq[Point]
    var tmpPoints1: seq[Point] = points1
    tmpPoints1.sort(Ascending)

    for p in points2:
        var i: int = tmpPoints1.binarySearch(p)
        if ( i != -1):
            if (tmpPoints1[i] != (0, 0)):
                intersectionPoints.add(tmpPoints1[i])
    
    return intersectionPoints



var inputFile: File
var wirePath1st: string
var wirePath2nd: string
var pathSeq1st: seq[Path]
var pathSeq2nd: seq[Path]

inputFile = open("./day3input.txt", fmRead)
# read 1st wire
wirePath1st = inputFile.readLine()
for path in wirePath1st.split(","):
    pathSeq1st.add(parsePath(path))
# read 2nd wire
wirePath2nd = inputFile.readLine()
for path in wirePath2nd.split(","):
    pathSeq2nd.add(parsePath(path))

close(inputFile)

# get points crossed by wire
var pointsCrossedBy1stWire: seq[Point] = getCrossedPoints(pathSeq1st)
var pointsCrossedBy2ndWire: seq[Point] = getCrossedPoints(pathSeq2nd)

# get intersection points
var intersectionPoints: seq[Point] =
    getIntersectionPoints(pointsCrossedBy1stWire, pointsCrossedBy2ndWire)

# calculate Manhattan distance
var manhattanDistance: seq[int]
for p in intersectionPoints:
    var mDis: int = abs(p.x) + abs(p.y)
    manhattanDistance.add(mDis)

echo manhattanDistance.min()

