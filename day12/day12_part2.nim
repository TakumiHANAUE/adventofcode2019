# Reference of how to solve
#  https://github.com/kaushalmodi/aoc2019/blob/master/day12/day12.nim
#  THANK YOU SO MUCH !!
#
# Each axis are independent each other, so you should calculate cycle of 
# returning initial position/velocity for each axis.
# Then calculate LCM of the cycles.

import strscans
import math

import moon

type
    JupiterMoon = enum 
        Io, Europa, Ganymede, Callisto

var moons: array[JupiterMoon, Moon]

# read input file
let fileName: string = "./day12input.txt"
var inputFile: File
inputFile = open(fileName, fmRead)
for i in JupiterMoon:
    var m: Moon = Moon()
    var pos: Position
    var line = inputFile.readLine()
    discard scanf(line, "<x=$i, y=$i, z=$i>", pos[AXIS_X], pos[AXIS_Y], pos[AXIS_Z])
    m.setPosition(pos)
    moons[i] = m
close(inputFile)

# reserve initial position and velocity
var initialPosition: array[JupiterMoon, Position]
var initialVelocity: array[JupiterMoon, Velocity]
for i in JupiterMoon:
    initialPosition[i] = moons[i].getPosition()
    initialVelocity[i] = moons[i].getVelocity()

var steps: array[Axis, uint] = [0'u, 0'u, 0'u]
for axis in Axis:
    var initialPositionOnAnAxis: array[JupiterMoon, int]
    var initialVelocityOnAnAxis: array[JupiterMoon, int]
    for i in JupiterMoon:
        initialPositionOnAnAxis[i] = initialPosition[i][axis]
        initialVelocityOnAnAxis[i] = initialVelocity[i][axis]
    while true:
        # calculate acceleration
        for i in JupiterMoon:
            for j in JupiterMoon:
                if i != j:
                    moons[i].calcAccelerationOnAnAxisAgainst(moons[j], axis)
        # update velocity, position
        var positionOnAnAxis: array[JupiterMoon, int]
        var velocityOnAnAxis: array[JupiterMoon, int]
        for i in JupiterMoon:
            moons[i].updateVelocityOnAnAxis(axis)
            moons[i].updatePositionOnAnAxis(axis)
            positionOnAnAxis[i] = moons[i].getPositionOnAnAxis(axis)
            velocityOnAnAxis[i] = moons[i].getVelocityOnAnAxis(axis)
        inc(steps[axis])
        # check position if the moon is at initial position
        if positionOnAnAxis == initialPositionOnAnAxis and velocityOnAnAxis == initialVelocityOnAnAxis:
            break

echo steps[AXIS_X].lcm(steps[AXIS_Y]).lcm(steps[AXIS_Z])
