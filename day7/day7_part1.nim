import system
import strutils
import opecode
import algorithm


var inputFile: File
var program: string
var phaseSeq: seq[int] = @[0, 1, 2, 3, 4]
var nthOpecode3: int = 0
var input: int = 0
var output: int = 0
var thrusterSignalSeq: seq[int]

while ( phaseSeq.nextPermutation() == true ):
    input = 0
    output = 0
    for phase in phaseSeq:
        
        input = output
        var programSeq: seq[int] = @[]
        nthOpecode3 = 0

        # store input intcode program
        inputFile = open("./day7input.txt", fmRead)
        program = inputFile.readAll()
        close(inputFile)
        for code in program.split(","):
            programSeq.add(parseInt(code))
        
        # run program
        var i: int = 0
        var pointerShift: int = 5
        while getInstCode(programSeq[i]) != 99:
            case getInstCode(programSeq[i])
            of 1:
                opeCode1(i, programSeq)
                pointerShift = 4
            of 2:
                opeCode2(i, programSeq)
                pointerShift = 4
            of 3:
                inc(nthOpecode3)
                if ( nthOpecode3 == 1 ):
                    opeCode3(i, programSeq, phase)
                elif ( nthOpecode3 == 2 ):
                    opeCode3(i, programSeq, input)
                else:
                    echo "nthOpecode3 >= 3 "
                pointerShift = 2
            of 4:
                output = opeCode4(i, programSeq)
                pointerShift = 2
            of 5:
                opeCode5(i, programSeq, pointerShift)
            of 6:
                opeCode6(i, programSeq, pointerShift)
            of 7:
                opeCode7(i, programSeq)
                pointerShift = 4
            of 8:
                opeCode8(i, programSeq)
                pointerShift = 4
            else:
                echo "ERR: Invalid opecode ", i, " ", programSeq[i]
                break
            inc(i, pointerShift)
            #echo programSeq
    
    thrusterSignalSeq.add(output)

echo "The highest thruster signal: ", thrusterSignalSeq.max
