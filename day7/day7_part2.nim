import system
import algorithm
import tables
import sequtils
import amplifier
import os


var ampA: Amplifier = Amplifier(name: "A")
var ampB: Amplifier = Amplifier(name: "B")
var ampC: Amplifier = Amplifier(name: "C")
var ampD: Amplifier = Amplifier(name: "D")
var ampE: Amplifier = Amplifier(name: "E")
ampA.setNextAmp(ampB)
ampB.setNextAmp(ampC)
ampC.setNextAmp(ampD)
ampD.setNextAmp(ampE)
ampE.setNextAmp(ampA)

let programFilePath: string = "./day7input.txt"
var phaseSeq: seq[int] = @[5, 6, 7, 8, 9]
let ampNameSeq: seq[string] = @["A", "B", "C", "D", "E"]
var phaseSettingTable = initTable[string, int]()
var thrusterSignalSeq: seq[int]

while ( phaseSeq.nextPermutation() == true ):
    # make phaseSettingTable
    for pairs in zip(ampNameSeq, phaseSeq):
        let (name, phase) = pairs
        phaseSettingTable[name] = phase
    echo phaseSettingTable

    # reset Amplifiers
    ampA.resetParams()
    ampB.resetParams()
    ampC.resetParams()
    ampD.resetParams()
    ampE.resetParams()
    # store input intcode program
    ampA.readProgram(programFilePath)
    ampB.readProgram(programFilePath)
    ampC.readProgram(programFilePath)
    ampD.readProgram(programFilePath)
    ampE.readProgram(programFilePath)
    # set phase value
    ampA.setPhaseValue(phaseSettingTable["A"])
    ampB.setPhaseValue(phaseSettingTable["B"])
    ampC.setPhaseValue(phaseSettingTable["C"])
    ampD.setPhaseValue(phaseSettingTable["D"])
    ampE.setPhaseValue(phaseSettingTable["E"])
    # set input value to first amplifier
    ampA.addInputValue(0)
    # power on
    ampA.powerOn()
    ampB.powerOn()
    ampC.powerOn()
    ampD.powerOn()
    ampE.powerOn()
    # run program
    while ampE.getRunnningState == true:
        # sleep(500)
        ampA.doOneInstruction()
        ampB.doOneInstruction()
        ampC.doOneInstruction()
        ampD.doOneInstruction()
        ampE.doOneInstruction()
    
    thrusterSignalSeq.add(ampE.getOutput())

echo "Highest Signal is ", thrusterSignalSeq.max()

