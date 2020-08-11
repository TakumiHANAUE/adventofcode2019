import sequtils
import algorithm
import strscans
import strutils

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

proc assignToWithResidual(r1: Reaction, r2: var Reaction, newResidual: var Term): bool =
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
            newResidual = ((r1.output.coeff - r2.input[targetTermIndex].coeff), r1.output.chemical)
            r2.input.delete(targetTermIndex)
            r2.input.insert(r1.input)
            assigned = true
    return assigned

proc termCmp(t1, t2: Term): int =
    return cmp(t1.chemical, t2.chemical)

proc simplifyTerms(termSeq: var seq[Term]): void =
    var sortedInput: seq[Term] = termSeq.sorted(termCmp, Ascending)
    termSeq = sortedInput

    var simplified: seq[Term] = @[]
    simplified.add(termSeq[0])
    for i in 1..termSeq.high:
        if termSeq[i].chemical == simplified[simplified.high].chemical:
            simplified[simplified.high].coeff += termSeq[i].coeff
        else:
            simplified.add(termSeq[i])
    termSeq = simplified

proc simplify(r1: var Reaction): void =
    r1.input.simplifyTerms()

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
var reactions: seq[Reaction]
var tmpReactions: seq[Reaction]

# amount of ORE
var oreNum: int = int(1000000000000)

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
        # oreReactions.add(r)
        tmpReactions.add(r)
    else:
        tmpReactions.add(r)


# sort reactions with considering dependency between chemicals
reactions = tmpReactions.sortReaction()

var residuals: seq[Term] = @[]
var fuel: int = 0

# assigning/simplifying reactions
while fuleReaction.inputChemicals != @["ORE"]:
    var assigned: bool = false
    # simple assigning
    for j in 0..reactions.high:
        if reactions[j].assignTo(fuleReaction) == true:
            fuleReaction.simplify()
            assigned = true
    # assigning with residual
    if assigned == false:
        for j in 0..reactions.high:
            var outres: Term
            if reactions[j].assignToWithResidual(fuleReaction, outres) == true:
                fuleReaction.simplify()
                residuals.add(outres)
                break

residuals.simplifyTerms()

# calc ORE amount
let oreAmount: int = fuleReaction.input[0].coeff

echo "Minimum amount of ORE for 1 FUEL : ", oreAmount


fuel = oreNum div oreAmount
inc(oreNum, -(oreAmount * fuel))

var allResiduals: Reaction
allResiduals.output = (0, "RESIDUALS")
allResiduals.input = residuals.times(fuel)
allResiduals.input.add((oreNum, "ORE"))

var canProduceFuel: bool = true
var canAssign: bool = true
while canProduceFuel == true or canAssign == true:
    canProduceFuel = true
    canAssign = true
    while canAssign == true:
        canAssign = false
        for j in 0..reactions.high:
            if reactions[j].assignTo(allResiduals) == true:
                allResiduals.simplify()
                canAssign = true
    
    for i in 0..allResiduals.input.high:
        if allResiduals.input[i].chemical == "ORE":
            var x = allResiduals.input[i].coeff div oreAmount
            if x > 0:
                allResiduals.input[i].coeff -= oreAmount * x
                allResiduals.input.insert(residuals.times(x))
                inc(fuel, x)
            else:
                canProduceFuel = false
            break
    allResiduals.simplify()

echo "Maximum amount of FUEL : ", fuel