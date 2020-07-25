import sequtils
import algorithm
import strscans
import strutils
import math

type
    Term = tuple[coeff: int, chemical: string]
    Reaction = tuple[output: Term, input: seq[Term]]

proc times(termSeq: seq[Term], n: int): seq[Term] =
    var outSeq: seq[Term]
    for it in termSeq.items:
        outSeq.add((it.coeff * n, it.chemical))
    return outSeq

proc assignTo(r1: Reaction, r2: var Reaction): bool =
    var assigned: bool = false
    var targetTermIndex: int = -1
    var foundSameChemical: bool = false
    for i in 0..r2.input.high:
        if r2.input[i].chemical == r1.output.chemical:
            targetTermIndex = i
            foundSameChemical = true
            break
    if foundSameChemical == true:
        if r2.input[targetTermIndex].coeff >= r1.output.coeff:
            var n = r2.input[targetTermIndex].coeff div r1.output.coeff
            r2.input[targetTermIndex].coeff -= r1.output.coeff * n
            if r2.input[targetTermIndex].coeff == 0:
                r2.input.delete(targetTermIndex)
            r2.input.insert(r1.input.times(n))
            assigned = true
    return assigned

proc assignToWithResidual(r1: Reaction, r2: var Reaction): bool =
    var assigned: bool = false
    var targetTermIndex: int = -1
    var foundSameChemical: bool = false
    for i in 0..r2.input.high:
        if r2.input[i].chemical == r1.output.chemical:
            targetTermIndex = i
            foundSameChemical = true
            break
    if foundSameChemical == true:
        if r2.input[targetTermIndex].coeff < r1.output.coeff:
            r2.input.delete(targetTermIndex)
            r2.input.insert(r1.input)
            assigned = true
    return assigned

proc termCmp(t1, t2: Term): int =
    return cmp(t1.chemical, t2.chemical)

proc simplify(r1: var Reaction): void =
    var sortedInput: seq[Term] = r1.input.sorted(termCmp, Ascending)
    r1.input = sortedInput

    var simplified: Reaction = (r1.output, @[])
    simplified.input.add(r1.input[0])
    for i in 1..r1.input.high:
        if r1.input[i].chemical == simplified.input[simplified.input.high].chemical:
            simplified.input[simplified.input.high].coeff += r1.input[i].coeff
        else:
            simplified.input.add(r1.input[i])
    r1 = simplified

proc inputChemicals(r: Reaction): seq[string] =
    var chemicals: seq[string]
    for i in 0..r.input.high:
        chemicals.add(r.input[i].chemical)
    chemicals.sort(Ascending)
    return chemicals.deduplicate(true)

proc sortReaction(rSeq: seq[Reaction]): seq[Reaction] =
    var ret: seq[Reaction]
    var sorted: bool = false
    ret = rSeq
    while sorted == false:
        var inserted: bool = false
        for i in 0..ret.high:
            for j in i..ret.high:
                for k in 0..ret[j].input.high:
                    if ret[j].input[k].chemical == ret[i].output.chemical:
                        ret.insert(ret[i], j + 1 )
                        ret.delete(i)
                        inserted = true
                        break
                    if inserted == true:
                        break
                if inserted == true:
                    break
            if inserted == true:
                break
        if inserted == false:
            sorted = true
    return ret

###########

# group reactions
var fuleReaction: Reaction
var oreReactions: seq[Reaction]
var reactions: seq[Reaction]
var tmpReactions: seq[Reaction]

# read input
let fileName: string = "./day14input.txt"
var inputFile: File
inputFile = open(fileName, fmRead)
for line in inputFile.lines:
    # read a reaction
    var rightSide: string
    var leftSide: string
    var r: Reaction
    discard scanf(line, "$* => $*\n", leftSide, rightSide)
    ## rightSide
    discard scanf(rightSide, "$i $w", r.output.coeff, r.output.chemical)
    ## leftside
    for t in leftSide.split(','):
        var coeff: int
        var chemical: string
        discard scanf(t, "$s$i $w", coeff, chemical)
        r.input.add((coeff, chemical))
    # group reaction
    if r.output.chemical == "FUEL":
        fuleReaction = r
    elif r.input[0].chemical == "ORE":
        oreReactions.add(r)
    else:
        tmpReactions.add(r)

for i in 0..tmpReactions.high:
    echo tmpReactions[i]
echo ""

# sort reactions with considering dependency between chemicals
reactions = tmpReactions.sortReaction()

# chemicals prodeced from ORE directly
var chemicalsFromORE: seq[string]
for i in 0..oreReactions.high:
    chemicalsFromORE.add(oreReactions[i].output.chemical)
chemicalsFromORE.sort(Ascending)

# assigning/simplifying reactions
while fuleReaction.inputChemicals != chemicalsFromORE:
    var assigned: bool = false
    # simple assigning
    for j in 0..reactions.high:
        if reactions[j].assignTo(fuleReaction) == true:
            fuleReaction.simplify()
            assigned = true
    # assigning with residual
    if assigned == false:
        for j in 0..reactions.high:
            if reactions[j].assignToWithResidual(fuleReaction) == true:
                fuleReaction.simplify()
                break

# calc ORE amount
var oreAmount: int = 0
for i in 0..fuleReaction.input.high:
    for j in 0..oreReactions.high:
        if fuleReaction.input[i].chemical == oreReactions[j].output.chemical:
            var x: float = float(fuleReaction.input[i].coeff) / float(oreReactions[j].output.coeff)
            oreAmount += int(ceil(x)) * oreReactions[j].input[0].coeff

echo "Minimum amount of ORE is ", oreAmount