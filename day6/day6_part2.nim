import system
import strutils
import tables
import algorithm

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

# get direct and indirect orbits from YOU
var orbitToYOU: seq[string]
var keyObject: string = "YOU"
while ( keyObject != "COM" ):
    if centerObjectTable.hasKey(keyObject):
        orbitToYOU.add(keyObject)
        keyObject = centerObjectTable[keyObject]
orbitToYOU.reverse

# get direct and indirect orbits from SAN
var orbitToSAN: seq[string]
keyObject  = "SAN"
while ( keyObject != "COM" ):
    if centerObjectTable.hasKey(keyObject):
        orbitToSAN.add(keyObject)
        keyObject = centerObjectTable[keyObject]
orbitToSAN.reverse

# search intersection object
var i: int = 0
while ( orbitToYOU[i] == orbitToSAN[i] ):
    if ( orbitToYOU[i] != orbitToSAN[i] ):
        break
    inc(i)
var objectIndex: int = i

# 
var orbitalTransfers: int = 0
orbitalTransfers = (orbitToYOU.high - objectIndex) + (orbitToSAN.high - objectIndex)

echo "The minimum number of orbital transfers required: ", orbitalTransfers