import deques
import opecode
import strutils

type
    Amplifier* = ref object of RootObj
        name*: string
        programSeq: seq[int]
        programPointer: int
        phase*: int
        phaseSettingDone: bool
        input: Deque[int]
        output: int
        isRunnning: bool
        nextAmp*: Amplifier

method powerOn*(amp: Amplifier): void {.base.} =
    amp.isRunnning = true

method resetParams*(amp: Amplifier): void {.base.} = 
    amp.programPointer = 0
    amp.programSeq = @[]
    amp.phase = 0
    amp.phaseSettingDone = false
    amp.input = initDeque[int]()
    amp.output = 0
    amp.isRunnning = false

method setNextAmp*(amp: Amplifier, nextAmplifier: Amplifier): void {.base.} =
    amp.nextAmp = nextAmplifier

method setPhaseValue*(amp: Amplifier, phaseValue: int): void {.base.} =
    amp.phase = phaseValue

method addInputValue*(amp: Amplifier, inputValue: int): void {.base.} =
    amp.input.addLast(inputValue)

method readProgram*(amp: Amplifier, programFilePath: string): void {.base.} =
    var inputFile: File = open(programFilePath, fmRead)
    var program: string = inputFile.readAll()
    close(inputFile)
    for code in program.split(","):
        amp.programSeq.add(parseInt(code))

method receiveInput(amp: Amplifier, inputValue: int): void {.base.} =
    amp.input.addLast(inputValue)
    # echo amp.name, " : Receive ", inputValue
    # echo amp.name, " : Input : ", amp.input

method getRunnningState*(amp: Amplifier): bool {.base.} =
    return amp.isRunnning

method getOutput*(amp: Amplifier): int {.base.} =
    return amp.output

method giveOutputTo(amp: Amplifier, ampGivenTo: Amplifier, outputValue: int): void {.base.} =
    if ampGivenTo.getRunnningState == true:
        # echo amp.name, " : Give output value ", outputValue, " to ", ampGivenTo.name
        ampGivenTo.receiveInput(outputValue)
    else:
        amp.output = outputValue
        echo amp.name, " : Output ", outputValue

method doOneInstruction*(amp: Amplifier): void {.base.} =
    if amp.isRunnning == true:
        var pointerShift: int = 0
        if getInstCode(amp.programSeq[amp.programPointer]) != 99:
            case getInstCode(amp.programSeq[amp.programPointer])
            of 1:
                opeCode1(amp.programPointer, amp.programSeq)
                pointerShift = 4
            of 2:
                opeCode2(amp.programPointer, amp.programSeq)
                pointerShift = 4
            of 3:
                if ( amp.phaseSettingDone == false ):
                    opeCode3(amp.programPointer, amp.programSeq, amp.phase)
                    amp.phaseSettingDone = true
                    pointerShift = 2
                else:
                    # echo amp.name, ": waiting input", " : input.len = ", amp.input.len(), " : ", amp.input
                    if amp.input.len() != 0:
                        opeCode3(amp.programPointer, amp.programSeq, amp.input.popFirst())
                        pointerShift = 2
            of 4:
                var outputValue = opeCode4(amp.programPointer, amp.programSeq)
                amp.giveOutputTo(amp.nextAmp, outputValue)
                pointerShift = 2
            of 5:
                opeCode5(amp.programPointer, amp.programSeq, pointerShift)
            of 6:
                opeCode6(amp.programPointer, amp.programSeq, pointerShift)
            of 7:
                opeCode7(amp.programPointer, amp.programSeq)
                pointerShift = 4
            of 8:
                opeCode8(amp.programPointer, amp.programSeq)
                pointerShift = 4
            else:
                echo "ERR: Invalid opecode ", amp.programPointer, " ", amp.programSeq[amp.programPointer]
            inc(amp.programPointer, pointerShift)
            # echo amp.name, "(", amp.programPointer, ") : ", amp.programSeq
        else:
            amp.isRunnning = false

