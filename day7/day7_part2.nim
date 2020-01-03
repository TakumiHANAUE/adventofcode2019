import system
import strutils
import opecode
import algorithm
import tables
import sequtils


var inputFile: File
var program: string
var phaseSeq: seq[int] = @[9, 7, 8, 5, 6]
let amplifiers: seq[string] = @["A", "B", "C", "D", "E"]
# phaseSettingTable(Amplifier ID, phase setting)
var phaseSetingTable = initTable[string, int]()
var nthOpecode3: int = 0
var input: int = 0
var output: int = 0
var thrusterSignalSeq: seq[int]
var phaseSettingDone: Table[string, bool]
    = {"A": false, "B": false, "C": false, "D": false, "E": false}.toTable

while ( phaseSeq.nextPermutation() == true ):
    # reset parameters
    input = 0
    output = 0
    for key in phaseSettingDone.keys:
        phaseSettingDone[key] = false
    # make phaseSettingTable
    for pairs in zip(amplifiers, phaseSeq):
        let (amp, phase) = pairs
        phaseSetingTable[amp] = phase
    echo phaseSetingTable

    for loop in 1..10:
        for key in phaseSettingDone.keys:
            phaseSettingDone[key] = false
        
        for amp in amplifiers:
            echo amp
            input = output
            var programSeq: seq[int] = @[]
            nthOpecode3 = 0

            # store input intcode program
            inputFile = open("../tmp.txt", fmRead)
            program = inputFile.readAll()
            close(inputFile)
            for code in program.split(","):
                programSeq.add(parseInt(code))
            
            # run program
            var i: int = 0
            var pointerShift: int = 0
            while getInstCode(programSeq[i]) != 99:
                case getInstCode(programSeq[i])
                of 1:
                    opeCode1(i, programSeq)
                    pointerShift = 4
                of 2:
                    opeCode2(i, programSeq)
                    pointerShift = 4
                of 3:
                    if ( phaseSettingDone[amp] == false ):
                        var phase: int = phaseSetingTable[amp]
                        opeCode3(i, programSeq, phase)
                        phaseSettingDone[amp] = true
                    else:
                        opeCode3(i, programSeq, input)
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
                echo programSeq

    thrusterSignalSeq.add(output)

echo "The highest thruster signal: ", thrusterSignalSeq.max
