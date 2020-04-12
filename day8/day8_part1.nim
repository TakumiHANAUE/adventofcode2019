import strutils

var inputFile: File
var imageData: string

const WIDTH: int = 25
const HEIGHT: int = 6
var image: seq[int] = @[]

type
    LayerInfo = object
        numberOfZero: int
        numberOfOne: int
        numberOfTwo: int

var layerInfo: LayerInfo = LayerInfo(numberOfZero: high(int))

inputFile = open("./day8input.txt", fmRead)
imageData = inputFile.readAll()
for i in 0..(imageData.len - 1):
    image.add( parseInt($(imageData[i])) )
    if image.len() == (WIDTH * HEIGHT):
        var zeroNum = count($image, '0')
        if zeroNum < layerInfo.numberOfZero:
            layerInfo.numberOfZero = count($image, '0')
            layerInfo.numberOfOne = count($image, '1')
            layerInfo.numberOfTwo = count($image, '2')
        image = @[]

echo layerInfo.numberOfOne * layerInfo.numberOfTwo

