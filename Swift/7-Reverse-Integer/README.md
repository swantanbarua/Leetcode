# 7. Reverse Integer

**Difficulty:** Medium · **Status:** Accepted · [Problem link](https://leetcode.com/problems/reverse-integer/)

> Given a signed 32-bit integer `x`, return `x` with its digits reversed. If reversing `x` causes
> the value to go outside the signed 32-bit integer range `[-2^31, 2^31 - 1]`, then return `0`.
>
> **Assume the environment does not allow you to store 64-bit integers (signed or unsigned).**

**Examples**

```
x = 123    →   321
x = -123   →  -321
x = 120    →    21
```

**Constraints**

- `-2^31 <= x <= 2^31 - 1`

---

## Step 1 — What are we actually being asked?

Flip the digits of a number back to front.

```
 1 2 3          →          3 2 1
 ▲   ▲                     ▲   ▲
first last               last first
```

Three small rules come with it:

- **Negative numbers keep their minus sign:** `-123 → -321`.
- **Zeros at the end disappear:** `120 → 021`, which is just `21`.
- **Too big means 0:** `1534236469` reversed is `9646324351`. That's bigger than the 32-bit
  limit (`2147483647`), so the answer is `0`.

### The idea: move the digits across, one at a time

Keep two boxes. Take the **last** digit off the number, and put it on the **end** of the answer.
Repeat until the number is empty.

```
remainingNumber:  123  →  12  →  1  →  0
reversed:           0  →   3  → 32  → 321
```

The running example for every step below is `x = 123`.

---

## Step 2 — An empty box for the answer

```swift
var reversed = 0
```

We build the answer in here one digit at a time. `0` is the blank sheet before you write
anything. It's a `var` because it changes every round: `0 → 3 → 32 → 321`.

| | `x` | `reversed` |
|---|---|---|
| Start | 123 | **0** |

---

## Step 3 — A copy of `x` that we can shrink

```swift
var remainingNumber = x
```

Each round cuts one digit off the end of this box. When it hits `0`, every digit has been used.

**Why not shrink `x` itself?** Function inputs in Swift are constants. `x /= 10` is a compile
error: *cannot assign to value: 'x' is a 'let' constant*. So we copy it into a `var`.

| | `remainingNumber` | `reversed` |
|---|---|---|
| Start | **123** | 0 |

---

## Step 4 — Keep going while there are digits left

```swift
while remainingNumber != 0 {

}
```

| Round | `remainingNumber` at the start | Run? |
|---|---|---|
| 1 | 123 | yes |
| 2 | 12 | yes |
| 3 | 1 | yes |
| — | 0 | **no, stop** |

**Why `!= 0` and not `> 0`?** `-123` is less than 0, so a `> 0` loop would never run for negative
input. `!= 0` works on both sides of zero.

---

## Step 5 — Pick off the last digit

```swift
let lastDigit = remainingNumber % 10
```

`%` is the **remainder** after dividing. The remainder after dividing by 10 is always the last
digit.

**Picture it with money:** ₹123 packed into bundles of ₹10 gives 12 bundles and ₹**3** left
over. That leftover is `123 % 10 = 3`.

```
remainingNumber = 1 2 3
                      ▲
            lastDigit = 3
```

**Negative numbers:** in Swift `-123 % 10` is `-3`. The minus sign comes along with the digit.

---

## Step 6 — Cut that digit off

```swift
remainingNumber /= 10
```

Dividing whole numbers (`Int`) throws away everything after the decimal point, so dividing by 10
drops the last digit. `/=` is short for `remainingNumber = remainingNumber / 10`.

```
123 / 10 = 12.3  →  Int keeps 12

before:  1 2 3
             ✂
after:   1 2
```

Same money picture: `%` gave the leftover (3), `/` gives the bundles (12). They always work as a
pair:

| Operation | Gives you | `123` |
|---|---|---|
| `% 10` | the last digit | `3` |
| `/ 10` | everything except the last digit | `12` |

`-123 / 10` is `-12`, so negatives work here too.

---

## Step 7 — Put the digit on the end of the answer

```swift
reversed = reversed * 10 + lastDigit
```

1. `* 10` moves every digit already in the answer one place left, which opens an empty slot on
   the right.
2. `+ lastDigit` puts the new digit into that slot.

**Picture a queue:** everyone takes one step left, and the new person joins at the right end.

```
Round 1:   0 * 10 + 3  =   3
Round 2:   3 * 10 + 2  =  32
Round 3:  32 * 10 + 1  = 321
```

**Trailing zeros vanish on their own.** For `x = 120`, round 1 gives `0 * 10 + 0 = 0`. Nothing
was added, so the answer ends up `21` with no extra code.

> In the finished code this line sits **below** the guard from Step 8. It's taught first because
> the guard only makes sense once you've seen the `* 10` it protects.

---

## Step 8 — Stop before the number gets too big

```swift
if reversed > Int32.max / 10 || reversed < Int32.min / 10 { return 0 }
```

This goes **just above** the line from Step 7. Right before we multiply by 10, it asks: *"if I
multiply this by 10, will it leave the 32-bit range?"* If yes, return `0` now.

```
Int32.max      =  2147483647
Int32.max / 10 =   214748364   ← largest value that is safe to multiply by 10
Int32.min      = -2147483648
Int32.min / 10 =  -214748364   ← smallest value that is safe to multiply by 10
```

**Picture a lift rated for 2147483647 kg.** You don't let people in and then weigh the lift,
because by then the cable has already snapped. You check at the door.

**Why before the multiply and not after?** The problem says we can't store 64-bit numbers. If we
multiplied first, the too-big number would already be stored in a variable. Checking
`reversed` against `max / 10` first means we never make a number past 32 bits. (Swift's `Int` is
64-bit, so checking afterwards would *happen* to pass on LeetCode, but it breaks the rule and
would crash in a real 32-bit setting.)

**"What if it's exactly 214748364?"** Then the next digit would have to be 8 or more to overflow.
For `reversed` to reach 9 digits, `x` must have 10 digits, and a 10-digit number that fits in 32
bits starts with `1` or `2`. That first digit is the last one added, so it's never more than `2`.
`>` alone is enough, and the same reasoning covers the negative side.

**On the danger case `x = 1534236469`:**

```
after 9 rounds:  reversed = 964632435
check:           964632435 > 214748364  → return 0   ✅
```

---

## Step 9 — Return the answer

```swift
return reversed
```

Outside the loop. If it were inside, the function would stop after round 1 and return `3`.

### Full trace on `x = 123`

| Round | `lastDigit` | `remainingNumber` after cut | Guard | `reversed` |
|---|---|---|---|---|
| 1 | 3 | 12 | ok (0) | 3 |
| 2 | 2 | 1 | ok (3) | 32 |
| 3 | 1 | 0 | ok (32) | 321 |
| | | loop stops | | **return 321** ✅ |

### Example 2, `x = -123`

| Round | `lastDigit` | `remainingNumber` after cut | Guard | `reversed` |
|---|---|---|---|---|
| 1 | -3 | -12 | ok | -3 |
| 2 | -2 | -1 | ok | -32 |
| 3 | -1 | 0 | ok | -321 |
| | | loop stops | | **return -321** ✅ |

### Example 3, `x = 120`

| Round | `lastDigit` | `remainingNumber` after cut | Guard | `reversed` |
|---|---|---|---|---|
| 1 | 0 | 12 | ok | 0 |
| 2 | 2 | 1 | ok | 2 |
| 3 | 1 | 0 | ok | 21 |
| | | loop stops | | **return 21** ✅ |

---

## The finished solution

```swift
class Solution {
    func reverse(_ x: Int) -> Int {
        
        var reversed = 0
        var remainingNumber = x

        while remainingNumber != 0 {
            let lastDigit = remainingNumber % 10
            remainingNumber /= 10
            if reversed > Int32.max / 10 || reversed < Int32.min / 10 { return 0 } 
            reversed = reversed * 10 + lastDigit
        }

        return reversed
    }
}
```

---

## Questions an interviewer will ask

| Question | Answer |
|---|---|
| Why not convert to a `String`, reverse it, and convert back? | It works but it's slower and uses O(digits) extra memory. You also have to handle the `-` sign separately, and `Int("9646324351")` would need 64-bit storage to detect overflow, which the problem forbids. The maths version uses O(1) space. |
| Why check overflow *before* multiplying? | Multiplying first could create a value that doesn't fit in 32 bits. The problem says we can't store one. Comparing with `Int32.max / 10` predicts the overflow without ever making the big number. |
| Why don't you check the last digit when `reversed == 214748364`? | The digit added last is the first digit of `x`. A 10-digit 32-bit input starts with 1 or 2, which is below the 7 (or 8 on the negative side) that would overflow. |
| How do negative numbers work without a special case? | Swift's `%` and `/` keep the sign: `-123 % 10 = -3`, `-123 / 10 = -12`. Every digit arrives negative, so the answer builds up negative. (Python is different: `-123 % 10 = 7`, so there you take `abs(x)` first.) |
| What about `x = -2147483648` (`Int32.min`)? | Reversed it would be `-8463847412`, which is out of range. The guard catches it at round 10 and returns 0. Taking `abs(x)` first would fail here in a real 32-bit type, because `2147483648` itself doesn't fit. Another reason to keep the sign. |
| Why `while remainingNumber != 0` instead of `> 0`? | `> 0` never runs for negative input. |

**The phrase that rebuilds this from scratch:**

> **take the last digit (% 10) → cut it off (/ 10) → check it's safe to grow → put it on the end (× 10 + digit) → repeat until nothing is left**

---

## Time and Space Complexity

### Time — O(log |x|)

The loop runs once per digit. A number `x` has about `log₁₀|x|` digits, so the work grows with
the **number of digits**, not with the size of the value.

| What we do | Cost |
|---|---|
| One round per digit | `log₁₀|x|` rounds, at most 10 for a 32-bit number |
| Per round: one `%`, one `/`, one comparison, one multiply-add | O(1) |

For any 32-bit input that's at most 10 rounds, which makes it effectively constant time.

### Space — O(1)

Three small variables (`reversed`, `remainingNumber`, `lastDigit`), however big `x` is. No
arrays, no strings.

### Can it be beaten?

No. Every digit has to be read to know where it goes, so O(digits) time is the floor, and O(1)
space can't be improved.
