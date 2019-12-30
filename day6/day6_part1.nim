import system
import strutils
import tables

var inputFile: File
# [key: orbitalObjec, value: centerObject]
var centerObjectTable = initTable[string, string]()

# read input file
var relation: seq[string]
inputFile = open("./day6input.txt", fmRead)
for line in inputFile.lines:
    relation = line.split(')')
    var centerObject: string = relation[0]
    var orbitalObject: string = relation[1]
    if not centerObjectTable.hasKey(orbitalObject):
        centerObjectTable[orbitalObject] = centerObject
    # ex. C)D -> "D": @["C"]

# search direct and indirect orbits
var numberOfOrbits: int = 0
for orbitalObject in centerObjectTable.keys:
    var keyObject: string = orbitalObject
    while ( keyObject != "COM" ):
        if centerObjectTable.hasKey(keyObject):
            inc(numberOfOrbits)
            keyObject = centerObjectTable[keyObject]

echo "The total number of direct and indirect orbits: ", numberOfOrbits