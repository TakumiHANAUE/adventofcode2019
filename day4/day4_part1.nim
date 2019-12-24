import sequtils
import algorithm

const RANGE_MIN = 178416
const RANGE_MAX = 676461

proc isSixDigits(i: int): bool =
    var iStr: string = $i
    if ( iStr.len == 6 ):
        result = true
    else:
        result = false

proc containDoubleDigit(i: int): bool =
    var iStr: string = $i
    if ( iStr.deduplicate() != iStr ):
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

var passwords: seq[int]
for i in RANGE_MIN..RANGE_MAX:
    if ( isSixDigits(i) == true ):
        if ( doesDigitsIncrease(i) == true ):
            if ( containDoubleDigit(i) == true ):
                passwords.add(i)

echo "The number of passwerd is ", passwords.len