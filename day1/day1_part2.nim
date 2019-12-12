import system
import strutils
import math

proc requiredFuel(mass: int): int =
    result = (mass / 3).floor.toInt - 2

var mass: int = 0
var fuel: int = 0
var allFuel: seq[int]

var inputFile: File
inputFile = open("./day1input.txt", fmRead)

for line in inputFile.lines:
    mass = parseInt(line)
    # fuel for module
    fuel = requiredFuel(mass)
    allFuel.add(fuel)

    #fuel for fuel
    fuel = requiredFuel(fuel)
    while fuel > 0:
        allFuel.add(fuel)
        fuel = requiredFuel(fuel)

# echo allFuel
echo allFuel.sum()
