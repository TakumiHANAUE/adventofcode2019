import strscans

import moon

const STEPS = 1000
type
    JupiterMoon = enum 
        Io, Europa, Ganymede, Callisto

var moons: seq[Moon]

let fileName: string = "./day12input.txt"
var inputFile: File
inputFile = open(fileName, fmRead)
for line in inputFile.lines:
    var m: Moon = Moon()
    var pos: Position
    discard scanf(line, "<x=$i, y=$i, z=$i>", pos[AXIS_X], pos[AXIS_Y], pos[AXIS_Z])
    m.setPosition(pos)
    moons.add(m)

for i in 1..STEPS:
    # calculate gravity
    for i in JupiterMoon:
        for j in JupiterMoon:
            if i != j:
                moons[int(i)].calcAccelerationAgainst(moons[int(j)])
    # update velocity, position
    for i in JupiterMoon:
        moons[int(i)].updateVelocity()
        moons[int(i)].updatePosition()

# calculate total energy in the system
var totalEnergy: uint = 0
for i in JupiterMoon:
    echo i
    moons[int(i)].printMoon()
    moons[int(i)].calcPotentioalEnergy()
    moons[int(i)].calcKineticEnergy()
    totalEnergy += moons[int(i)].calcTotalEnergy()
echo "Total Energy: ", totalEnergy
