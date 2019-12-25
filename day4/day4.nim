import sequtils
import algorithm
import strutils

const RANGE_MIN = 178416
const RANGE_MAX = 676461

proc isSixDigits(i: int): bool =
    let iStr: string = $i
    if ( iStr.len == 6 ):
        result = true
    else:
        result = false
        
proc doesDigitsIncrease(i: int): bool =
    let iStr: string = $i
    var iStrSorted: string = $i
    iStrSorted.sort(Ascending)
    if (  iStrSorted == iStr ):
        result = true
    else:
        result = false

proc containDoubleDigit(i: int): bool =
    let iStr: string = $i
    if ( iStr.deduplicate() != iStr ):
        result = true
    else:
        result = false

proc isNotPartOfLargerGroup(i: int): bool =
    var countDigit: array[0..9, int]
    let iStr: string = $i
    for digit in iStr:
        countDigit[parseInt($digit)].inc()
    
    if ( countDigit.find(2) != -1 ):
        result = true
    else:
        result = false


var passwordsPart1: seq[int]
var passwordsPart2: seq[int]
for i in RANGE_MIN..RANGE_MAX:
    if ( isSixDigits(i) == true ):
        if ( doesDigitsIncrease(i) == true ):
            if ( containDoubleDigit(i) == true ):
                passwordsPart1.add(i)
                if ( isNotPartOfLargerGroup(i) == true ):
                    passwordsPart2.add(i)

echo "The number of password(Part1) is ", passwordsPart1.len
echo "The number of password(Part2) is ", passwordsPart2.len