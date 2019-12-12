import system
import math
import strutils

var mass: int = 0
var fuel: int = 0
var totalFuel: int = 0

var inputFile: File
inputFile = open("./day1input.txt", fmRead)

for line in inputFile.lines:
    mass = parseInt(line)
    fuel = (mass / 3).floor.toInt - 2
    inc(totalFuel, fuel)

echo totalFuel
