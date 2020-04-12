import strutils

var inputFile: File
var imageData: string

const WIDTH: int = 25
const HEIGHT: int = 6
# const BLACK: int = 0
# const WHITE: int = 1
const TRANSPARENT: int = 2

type
    LayerRow = array[WIDTH, int]
    LayerImage = array[HEIGHT, LayerRow]

var fullImage: seq[LayerImage] = @[]
var layer: LayerImage

# read full image
inputFile = open("./day8input.txt", fmRead)
imageData = inputFile.readAll()
for i in 0..(imageData.len - 1):
    var yCoord: int = ((i div WIDTH) mod HEIGHT)
    var xCoord: int = (i mod WIDTH)
    layer[yCoord][xCoord] = parseInt($(imageData[i]))
    if (yCoord == (HEIGHT - 1)) and (xCoord == (WIDTH - 1)):
        fullImage.add(layer)

# Initialize decodedImage to value TRANSPARENT(2)
var decodedImage: LayerImage
for y in 0..(HEIGHT - 1):
    for x in 0..(WIDTH - 1):
        decodedImage[y][x] = TRANSPARENT

# output decoded image
for y in 0..(HEIGHT - 1):
    for x in 0..(WIDTH - 1):
        for i in 0..(fullImage.len - 1):
            if decodedImage[y][x] == TRANSPARENT:
                decodedImage[y][x] = (fullImage[i])[y][x]
        stdout.write decodedImage[y][x]
    echo ""
