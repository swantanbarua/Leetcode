# 4. Median of Two Sorted Arrays

**Difficulty:** Hard · **Status:** Accepted · [Problem link](https://leetcode.com/problems/median-of-two-sorted-arrays/)

> Given two sorted arrays `nums1` and `nums2` of size `m` and `n` respectively, return
> **the median** of the two sorted arrays.
>
> The overall run time complexity should be `O(log (m+n))`.

**Examples**

```
nums1 = [1,3], nums2 = [2]     →   2.0     merged = [1,2,3], the middle is 2
nums1 = [1,2], nums2 = [3,4]   →   2.5     merged = [1,2,3,4], middle two are 2 and 3, (2+3)/2 = 2.5
```

**Constraints**

- `nums1.length == m`, `nums2.length == n`
- `0 <= m <= 1000`, `0 <= n <= 1000`
- `1 <= m + n <= 2000`
- `-10^6 <= nums1[i], nums2[i] <= 10^6`

---

## Step 1 — What are we actually being asked?

You get two lists of numbers. Each list is **already sorted** from small to big. If you poured
both into one sorted list, the **median** is the number sitting in the middle.

```
[1, 2, 3]          odd count   →  one middle number: 2
[1, 2, 3, 4]       even count  →  two middle numbers, 2 and 3  →  average them: 2.5
```

### The catch

Merging the two arrays and picking the middle is easy, but it's `O(m + n)`. The problem asks
for `O(log(m + n))`. Whenever a problem says "log" and the input is sorted, the tool it wants
is **binary search**. So the question is really: *how do you find the middle without merging?*

### The idea: one line is really two lines

Take the merged list and draw a line through its middle:

```
left side  |  right side
   1   2   |   3
```

Two things are true about that line:

1. **Count:** the left side holds exactly half the numbers (2 of 3 — the extra one goes left).
2. **Order:** everything on the left ≤ everything on the right.

Now notice that this one line in the merged list is really **two lines**, one in each
original array:

```
nums1:   2 |            (1 number from nums1 went to the left)
nums2:   1 | 3          (1 number from nums2 went to the left)
```

Left side = `2` and `1`. Right side = `3`. Same split, same median — **and nothing was merged.**

So the whole problem becomes: *find where to draw the two lines.* And here's the trick that
makes it fast — once we decide where the line goes in `nums1`, the line in `nums2` is
**forced** by the count rule. So we only search for **one** line, and because `nums1` is
sorted, we can binary-search for it.

The plan, in one sentence:

> **Guess how many numbers `nums1` contributes to the left side. `nums2` contributes the
> rest. Check whether everything on the left ≤ everything on the right. If not, the check
> tells you which way to move the guess.**

Two examples run through every step below:

- **the LeetCode example** `nums1 = [1, 3]`, `nums2 = [2]` — tiny, so it hits every edge case
- **a bigger example** `nums1 = [1, 4, 7, 9]`, `nums2 = [2, 3, 5, 8, 10]` — so the four
  numbers next to the line are all real and visible

---

## Step 2 — Make `nums1` the shorter array

```swift
if nums1.count > nums2.count {
    return findMedianSortedArrays(nums2, nums1)
}
```

**Plain words:** "If the first array is longer than the second, call this same function again
with the two arrays handed over in the opposite order, and return whatever that call returns."

Picture it as two boxes:

```
┌─ Box 1 ──────────────────────────────────────────────┐
│  nums1 = [1, 3]   nums2 = [2]                        │
│  is 2 > 1 ?  YES  →  call again with ([2], [1, 3])   │
│                      and hand back its answer        │
└──────────────────────────────────────────────────────┘
                          ▼
┌─ Box 2 ──────────────────────────────────────────────┐
│  nums1 = [2]      nums2 = [1, 3]                     │
│  is 1 > 2 ?  NO   →  skip the if, do the real work   │
│                      here, answer 2.0                │
└──────────────────────────────────────────────────────┘
```

`nums1` and `nums2` are just labels. Box 1 called `[1, 3]` "nums1"; Box 2 calls `[2]` "nums1".
Box 1 does nothing else — its `return` means "Box 2's answer is my answer". The real work
happens once, in Box 2, where `nums1` is guaranteed to be the shorter array.

**Why does the short one have to be `nums1`?** This pays off in Step 6, but here is the reason
up front. Later, we pick how many numbers to take from `nums1`, and `nums2` must supply the
rest. Think of two piles of coins where your left hand must hold exactly `half` coins:

```
WITHOUT the swap:  nums1 = [1,2,3,4,5]  (5 coins)   nums2 = [6]  (1 coin)   half = 3

   take from nums1     nums2 must give     possible?
        0                  3 - 0 =  3      NO — nums2 has only 1 coin
        1                  3 - 1 =  2      NO
        2                  3 - 2 =  1      yes
        3                  3 - 3 =  0      yes
        4                  3 - 4 = -1      NO — minus one coin?
        5                  3 - 5 = -2      NO

WITH the swap:     nums1 = [6]  (1 coin)   nums2 = [1,2,3,4,5]  (5 coins)   half = 3

        0                  3 - 0 =  3      yes
        1                  3 - 1 =  2      yes
```

When the short pile decides, the long pile always has enough left over. In code, "not
possible" means reading `nums2[-1]` or `nums2[3]` on a 1-element array — a crash. The swap
makes every guess safe.

**On the LeetCode example:** `2 > 1`, so we swap. From here on `nums1 = [2]`, `nums2 = [1, 3]`.
**On the bigger example:** `4 > 5` is false, no swap.

---

## Step 3 — How many numbers belong on the left side

```swift
let nums1Size = nums1.count
let nums2Size = nums2.count
let half = (nums1Size + nums2Size + 1) / 2
```

`nums1Size` and `nums2Size` are the two lengths. `half` is **how many numbers must sit on the
left of the line** for the line to be in the middle.

**Why is that number fixed?** Because "median" *means* the middle, and the middle has the same
amount on both sides. Move the line anywhere else and you get some other number:

```
1  2  3  4          (4 numbers, half = 2)

  | 1 2 3 4        0 left, 4 right  →  not the middle
1 | 2 3 4          1 left, 3 right  →  not the middle
1 2 | 3 4          2 left, 2 right  →  THE middle. median = (2 + 3) / 2
1 2 3 | 4          3 left, 1 right  →  not the middle
```

**Why `+ 1`?** Integer division throws away the remainder. With an odd total someone has to
get the extra number, and the `+ 1` gives it to the **left**:

```
total 4:  (4 + 1) / 2 = 5 / 2 = 2      same as without the +1
total 3:  (3 + 1) / 2 = 4 / 2 = 2      without the +1 it would be 3 / 2 = 1
```

That's a deliberate choice: for an odd total, the median is then simply *the biggest number
on the left*. We cash that in at Step 10.

```
LeetCode example:  nums1Size = 1, nums2Size = 2   →   half = (1 + 2 + 1) / 2 = 2
bigger example:    nums1Size = 4, nums2Size = 5   →   half = (4 + 5 + 1) / 2 = 5
```

---

## Step 4 — The guessing range

```swift
var low = 0
var high = nums1Size
```

Think of the number-guessing game: "I'm thinking of a number between 0 and 10." You guess 5.
"Higher." Now it's between 6 and 10. `low` and `high` are the two ends of "the answer is
somewhere between here and here".

What we're guessing is **how many numbers to take from the front of `nums1`** for the left
side. Fewest possible: `0` (take none). Most possible: `nums1Size` (take all).

```
nums1 = [1, 4, 7, 9]      (nums1Size = 4)

take 0:    | 1  4  7  9
take 1:  1 | 4  7  9
take 2:  1  4 | 7  9
take 3:  1  4  7 | 9
take 4:  1  4  7  9 |
```

Five places for the line, so the range is `0...4`. That's why `high = nums1Size` and not
`nums1Size - 1` — we're counting *how many*, not *which index*. And it's `nums1Size`, not
`nums2Size`, because we're counting numbers taken **from `nums1`**.

They're `var` because each round of the loop moves one of them.

```
LeetCode example:  low = 0, high = 1      (take 0 or take 1 from [2])
bigger example:    low = 0, high = 4
```

---

## Step 5 — Start the loop and guess the middle

```swift
while low <= high {
    let takeFromNums1 = (low + high) / 2
```

- `while low <= high` — keep guessing while there's still a range to guess in. When `low`
  passes `high`, nothing is left.
- `takeFromNums1 = (low + high) / 2` — guess the **middle** of the range. Each wrong guess
  then throws away half of what's left, which is what makes this `log` time.

```
LeetCode example:  takeFromNums1 = (0 + 1) / 2 = 0      →   nums1:    | 2
bigger example:    takeFromNums1 = (0 + 4) / 2 = 2      →   nums1:  1  4 | 7  9
```

---

## Step 6 — `nums2` supplies the rest

```swift
    let takeFromNums2 = half - takeFromNums1
```

The left side must hold exactly `half` numbers. `nums1` gave `takeFromNums1`, so `nums2` must
give the rest. This is the seesaw: **more from `nums1` means less from `nums2`**, and the total
on the left never changes.

This is the line Step 2 was protecting. Because `nums1` is the shorter array,
`takeFromNums2` always lands between `0` and `nums2Size`.

```
LeetCode example:  takeFromNums2 = 2 - 0 = 2

    nums1:      | 2
    nums2:  1 3 |
    left side = 1, 3       right side = 2      count is right (2 and 1), but 3 is left of 2 ✗

bigger example:    takeFromNums2 = 5 - 2 = 3

    nums1:  1  4 | 7  9
    nums2:  2  3  5 | 8  10
    left side = 1, 4, 2, 3, 5     right side = 7, 9, 8, 10
```

---

## Step 7 — The four numbers touching the line

```swift
    let nums1Left = takeFromNums1 == 0 ? Int.min : nums1[takeFromNums1 - 1]
    let nums1Right = takeFromNums1 == nums1Size ? Int.max : nums1[takeFromNums1]
    let nums2Left = takeFromNums2 == 0 ? Int.min : nums2[takeFromNums2 - 1]
    let nums2Right = takeFromNums2 == nums2Size ? Int.max : nums2[takeFromNums2]
```

To check "left ≤ right" we don't scan everything. Both arrays are sorted, so only the numbers
**right next to the line** matter:

```
index:    0   1   2   3
nums1:    1   4 | 7   9
              ^   ^
      nums1Left   nums1Right
```

- `nums1Left` = the **last number we took** = `nums1[takeFromNums1 - 1]`. It's the biggest
  thing `nums1` put on the left.
- `nums1Right` = the **first number we did not take** = `nums1[takeFromNums1]`. It's the
  smallest thing `nums1` left on the right.

Same for `nums2` with `takeFromNums2`.

### Running the four lines on the bigger example

`takeFromNums1 = 2`, `takeFromNums2 = 3`, `nums1Size = 4`, `nums2Size = 5`:

```
nums1Left:   2 == 0 ?  no  →  nums1[2 - 1] = nums1[1] = 4
nums1Right:  2 == 4 ?  no  →  nums1[2]               = 7
nums2Left:   3 == 0 ?  no  →  nums2[3 - 1] = nums2[2] = 5
nums2Right:  3 == 5 ?  no  →  nums2[3]               = 8

              left of line  |  right of line
nums1:    1   [4]           |  [7]   9
nums2:    2   3   [5]       |  [8]   10
```

The whole left side is `1, 4, 2, 3, 5` and its biggest is `5` = `nums2Left`. The whole right
side is `7, 9, 8, 10` and its smallest is `7` = `nums1Right`. The four bracketed numbers are
the only ones that can touch across the line.

### The edges — where `Int.min` and `Int.max` come from

If we took **0** from an array, there is no "last number taken" — `nums1[-1]` doesn't exist.
If we took **all**, there is no "first number not taken". We still need *something* in those
variables so the comparison in Step 8 works:

```
takeFromNums1 = 0:     | 1  4  7  9       nothing before the line  →  nums1Left  = Int.min
takeFromNums1 = 4:   1  4  7  9 |         nothing after the line   →  nums1Right = Int.max
```

`Int.min` is the smallest number Swift has, so an *empty* left side can never look "too big".
`Int.max` is the biggest, so an empty right side can never look "too small". A missing number
should never be the reason a cut is rejected. That's all the `condition ? a : b` does:
*"if at the edge, use the stand-in; otherwise the real number."*

The LeetCode example hits **both** edges on its first guess:

```
nums1:      | 2      took 0    →  nums1Left = Int.min          nums1Right = nums1[0] = 2
nums2:  1 3 |        took all  →  nums2Left = nums2[1] = 3     nums2Right = Int.max
```

---

## Step 8 — Is this cut correct?

```swift
    if nums1Left <= nums2Right && nums2Left <= nums1Right {
```

The cut is correct when **everything on the left ≤ everything on the right**. There are four
left-vs-right pairs, but two of them are free:

| pair | needs checking? |
|---|---|
| `nums1Left ≤ nums1Right` | no — same array, it's sorted, always true |
| `nums2Left ≤ nums2Right` | no — same array, it's sorted, always true |
| `nums1Left ≤ nums2Right` | **yes** — different arrays, could fail |
| `nums2Left ≤ nums1Right` | **yes** — different arrays, could fail |

Only the two **cross** pairs can go wrong, and those are exactly the two in the `if`:

```
nums1:   ... nums1Left | nums1Right ...
                     ╲   ╱
                      ╳
                     ╱   ╲
nums2:   ... nums2Left | nums2Right ...
```

A way to remember it: in both checks the variable ending in **`Left` comes first** and the
one ending in **`Right` comes second** — left ≤ right, always.

### On the bigger example (the correct cut)

```
nums1Left = 4     nums1Right = 7
nums2Left = 5     nums2Right = 8

if  nums1Left <= nums2Right  &&  nums2Left <= nums1Right
if      4     <=     8       &&      5     <=     7
if          true             &&          true              →  enter the if
```

Left check: the biggest thing `nums1` put on the left (`4`) is not bigger than the smallest
thing `nums2` kept on the right (`8`). `nums1` did not over-give.
Right check: the biggest thing `nums2` put on the left (`5`) is not bigger than the smallest
thing `nums1` kept on the right (`7`). `nums2` did not over-give.

So every left number (`1, 4, 2, 3, 5`) ≤ every right number (`7, 9, 8, 10`). The line is in
the middle.

### On the LeetCode example (first guess, wrong)

```
nums1Left = -inf     nums1Right = 2
nums2Left = 3        nums2Right = +inf

-inf <= +inf   →  true
   3 <= 2      →  FALSE              →  skip the if
```

`nums2` put a `3` on the left while `nums1` still has a `2` on the right. Not sorted across
the line, so not the middle.

---

## Step 9 — The cut is wrong: which way to move?

```swift
    } else if nums1Left > nums2Right {
        high = takeFromNums1 - 1
    } else {
        low = takeFromNums1 + 1
    }
}
```

If the `if` failed, one of the two cross-checks was false, and each one tells us the direction:

```
nums1Left > nums2Right   →  nums1 gave too much  →  take fewer from nums1  →  high = guess - 1
nums2Left > nums1Right   →  nums2 gave too much  →  take MORE from nums1   →  low  = guess + 1
```

The second one looks odd at first: `nums2` over-gave, so why touch `nums1`? Because we don't
control `nums2` directly — `takeFromNums2 = half - takeFromNums1`. The only way to make `nums2`
give fewer is to make `nums1` give more. That's the seesaw again.

The plain `else` needs no condition: if the `if` failed and it wasn't the first check, it must
have been the second.

### The `else if` on the bigger example — `nums1` gave too much

Guess `takeFromNums1 = 3`, so `takeFromNums2 = 5 - 3 = 2`:

```
nums1:    1   4  [7] | [9]
nums2:    2  [3] |    [5]   8   10

nums1Left = 7     nums1Right = 9
nums2Left = 3     nums2Right = 5

if       7 <= 5  &&  3 <= 9     →  false && true  →  false, skip
else if  7 > 5                  →  true, enter
```

A `7` sitting left of a `5` is out of order, and the `7` came from `nums1`. So the correct
guess is *smaller* than 3:

```
high = 3 - 1 = 2
range before:  0 1 2 3 4
range after:   0 1 2
```

### The `else` on the bigger example — `nums2` gave too much

Guess `takeFromNums1 = 1`, so `takeFromNums2 = 5 - 1 = 4`:

```
nums1:   [1] | [4]   7   9
nums2:    2   3   5  [8] | [10]

nums1Left = 1     nums1Right = 4
nums2Left = 8     nums2Right = 10

if       1 <= 10  &&  8 <= 4    →  true && false  →  false, skip
else if  1 > 10                 →  false, skip
else                            →  enter
```

An `8` sitting left of a `4` is out of order, and the `8` came from `nums2`. `nums1` must take
more, so the correct guess is *bigger* than 1:

```
low = 1 + 1 = 2
range before:  0 1 2 3 4
range after:       2 3 4
```

Both branches shrink the range, and the guess eventually lands on `takeFromNums1 = 2` — the
correct cut we verified in Step 8.

---

## Step 10 — Read the median off the correct cut

```swift
        let maxLeft = max(nums1Left, nums2Left)
        let minRight = min(nums1Right, nums2Right)

        if (nums1Size + nums2Size) % 2 == 1 {
            return Double(maxLeft)
        }

        return Double(maxLeft + minRight) / 2.0
```

We're inside the `if`, so the cut is correct and the median is touching the line.

- `maxLeft` — the biggest number on the whole left side. The left side is two pieces, and each
  piece's biggest is `nums1Left` / `nums2Left`, so take the bigger of the two.
- `minRight` — the smallest number on the whole right side = the smaller of
  `nums1Right` / `nums2Right`.

Then:

- **Odd total** — Step 3 gave the extra number to the left, so the middle number is the last
  one on the left: `maxLeft`.
- **Even total** — the two middle numbers are the last on the left and the first on the right.
  Average them.

`Double(...)` is only because the function must return a `Double`.

```
bigger example (cut takeFromNums1 = 2):
    maxLeft  = max(4, 5) = 5
    minRight = min(7, 8) = 7
    total 9 is odd  →  return 5.0        merged: 1 2 3 4 5 | 7 8 9 10  ✓
```

---

## Step 11 — The `return 0.0` at the bottom

```swift
return 0.0
```

Swift requires every path through the function to return something. The loop always finds a
valid cut (the problem guarantees `m + n >= 1`, and a valid cut always exists for sorted
input), so this line never runs. It only satisfies the compiler.

---

## Step 12 — Watch it run on the LeetCode examples

### Example 1: `nums1 = [1, 3]`, `nums2 = [2]` → 2.0

After the swap: `nums1 = [2]`, `nums2 = [1, 3]`, `half = 2`, `low = 0`, `high = 1`.

| round | `takeFromNums1` | `takeFromNums2` | picture | `nums1Left` | `nums1Right` | `nums2Left` | `nums2Right` | checks | action |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `(0+1)/2 = 0` | `2 - 0 = 2` | `\| 2` / `1 3 \|` | `-inf` | `2` | `3` | `+inf` | `-inf ≤ +inf` ✓, `3 ≤ 2` ✗ | `else` → `low = 1` |
| 2 | `(1+1)/2 = 1` | `2 - 1 = 1` | `2 \|` / `1 \| 3` | `2` | `+inf` | `1` | `3` | `2 ≤ 3` ✓, `1 ≤ +inf` ✓ | correct cut |

```
maxLeft  = max(2, 1)    = 2
minRight = min(+inf, 3) = 3
total 3 is odd  →  return 2.0  ✓
```

### Example 2: `nums1 = [1, 2]`, `nums2 = [3, 4]` → 2.5

No swap. `half = 2`, `low = 0`, `high = 2`.

| round | `takeFromNums1` | `takeFromNums2` | picture | `nums1Left` | `nums1Right` | `nums2Left` | `nums2Right` | checks | action |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `(0+2)/2 = 1` | `2 - 1 = 1` | `1 \| 2` / `3 \| 4` | `1` | `2` | `3` | `4` | `1 ≤ 4` ✓, `3 ≤ 2` ✗ | `else` → `low = 2` |
| 2 | `(2+2)/2 = 2` | `2 - 2 = 0` | `1 2 \|` / `\| 3 4` | `2` | `+inf` | `-inf` | `3` | `2 ≤ 3` ✓, `-inf ≤ +inf` ✓ | correct cut |

```
maxLeft  = max(2, -inf) = 2
minRight = min(+inf, 3) = 3
total 4 is even  →  (2 + 3) / 2.0 = 2.5  ✓
```

---

## A bug that is easy to make

The first version of this solution had the second cross-check written backwards:

```swift
if nums1Left <= nums2Right && nums1Right <= nums2Left {     // ✗ wrong
```

That second check asks "is a RIGHT number ≤ a LEFT number?" — the *opposite* of sorted order.
On the bigger example's correct cut it does this:

```
wrong:    4 <= 8  &&  7 <= 5   →  true && FALSE  →  the correct cut is rejected
correct:  4 <= 8  &&  5 <= 7   →  true && true   →  accepted
```

With the correct cut rejected, the code falls into the `else`, keeps moving `low` up, and
either returns a wrong answer or runs off the end to `return 0.0`. The fix is one swap:

```swift
if nums1Left <= nums2Right && nums2Left <= nums1Right {     // ✓ left ≤ right, both times
```

---

## The finished solution

```swift
class Solution {
    func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
        
        if nums1.count > nums2.count {
            return findMedianSortedArrays(nums2, nums1)
        }

        let nums1Size = nums1.count
        let nums2Size = nums2.count
        let half = (nums1Size + nums2Size + 1) / 2

        var low = 0
        var high = nums1Size

        while low <= high {
            let takeFromNums1 = (low + high) / 2
            let takeFromNums2 = half - takeFromNums1

            let nums1Left = takeFromNums1 == 0 ? Int.min : nums1[takeFromNums1 - 1]
            let nums1Right = takeFromNums1 == nums1Size ? Int.max : nums1[takeFromNums1]
            let nums2Left = takeFromNums2 == 0 ? Int.min : nums2[takeFromNums2 - 1]
            let nums2Right = takeFromNums2 == nums2Size ? Int.max : nums2[takeFromNums2]

            if nums1Left <= nums2Right && nums2Left <= nums1Right {
                let maxLeft = max(nums1Left, nums2Left)
                let minRight = min(nums1Right, nums2Right)

                if (nums1Size + nums2Size) % 2 == 1 {
                    return Double(maxLeft)
                }

                return Double(maxLeft + minRight) / 2.0
            } else if nums1Left > nums2Right {
                high = takeFromNums1 - 1
            } else {
                low = takeFromNums1 + 1
            }
        }

        return 0.0
    }
}
```

---

## Questions an interviewer will ask

| Question | Answer |
|---|---|
| What's the simple solution? | Merge the two arrays and pick the middle. O(m + n) time and space. Correct, but not the O(log) the problem asks for. |
| Can you do better than merging but still simple? | Yes — walk two pointers until you've passed `(m + n) / 2` elements, no merged array needed. O(m + n) time, O(1) space. Still not logarithmic. |
| Why binary search? | The arrays are sorted, and the thing we're looking for — how many of `nums1` go left — is a single number in a fixed range `0...m`. The cross-check tells us whether the guess is too high or too low, which is exactly what binary search needs. |
| Why binary-search on the shorter array? | So `half - takeFromNums1` can never be negative or exceed the longer array's size. It also makes the search O(log(min(m, n))). |
| Why `(m + n + 1) / 2` and not `(m + n) / 2`? | For an odd total it puts the extra element on the left, so the odd-case median is just `maxLeft`. For an even total the `+ 1` changes nothing. |
| Why only two comparisons in the `if`? | Within one sorted array, "before the line ≤ after the line" is automatic. Only the two cross-array pairs can fail. |
| Why `Int.min` / `Int.max`? | When a cut leaves one side of an array empty, there's no real number to compare. The stand-ins can never be the reason a cut fails. |
| When `nums2Left > nums1Right`, why move `low` and not `high`? | `nums2` over-gave, but `takeFromNums2` is derived from `takeFromNums1`. Making `nums1` give more is the only way to make `nums2` give less. |
| What if one array is empty? | The swap makes the empty one `nums1`, so `low = high = 0`, `takeFromNums1 = 0`, `takeFromNums2 = half`, and the stand-ins make the first cut succeed. The median is read straight from `nums2`. |
| Is `return 0.0` reachable? | No. A valid cut always exists for sorted input with `m + n >= 1`. It only satisfies the compiler. |

**The three phrases that rebuild this from scratch:**

> **short array decides how many go left → the other array gives the rest → left ≤ right across the line, else move the guess**

---

## Time and Space Complexity

### Time — O(log(min(m, n)))

We binary-search over `takeFromNums1`, whose range is `0...nums1Size`, and `nums1` is the
shorter array. Every round halves the range and does a fixed amount of work:

| What we do | Cost |
|---|---|
| compute `takeFromNums1`, `takeFromNums2` | O(1) |
| read the four neighbours | O(1) |
| two comparisons | O(1) |
| move `low` or `high` | O(1) |

Halving a range of size `min(m, n)` down to nothing takes about `log₂(min(m, n))` rounds.
For the constraints (`m, n ≤ 1000`) that's at most ~10 rounds. This is better than the
`O(log(m + n))` the problem asks for.

### Space — O(1)

A handful of integers. No merged array, no extra collection. The swap's recursive call
happens at most once, so it doesn't add a stack of any depth.

### Can it be beaten?

**Not meaningfully.** Any algorithm has to distinguish between the `m + 1` possible cut
positions, and with only comparisons as information, that needs at least `log₂(m + 1)`
steps. Binary search over the shorter array is already at that floor.
