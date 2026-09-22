# 5. Longest Palindromic Substring

**Difficulty:** Medium · **Status:** Accepted · [Problem link](https://leetcode.com/problems/longest-palindromic-substring/)

> Given a string `s`, return the **longest palindromic substring** in `s`.

**Examples**

```
s = "babad"   →   "bab"     "aba" is also a valid answer
s = "cbbd"    →   "bb"
```

**Constraints**

- `1 <= s.length <= 1000`
- `s` consists of only digits and English letters.

---

## Step 1 — What are we actually being asked?

Two words to be clear on.

A **substring** is a piece of the string taken **without skipping** any letters. In `"babad"`,
`"bab"` and `"aba"` are substrings. `"bbd"` is not — you skipped letters to make it.

A **palindrome** reads the same left-to-right and right-to-left. `"bab"` reversed is `"bab"`.
`"bad"` reversed is `"dab"` — not a palindrome.

So: find the longest piece (no skipping) that reads the same both ways, and return the piece
itself, not just its length.

```
"babad"

piece     reversed   palindrome?
"b"       "b"        yes  (length 1)
"ba"      "ab"       no
"bab"     "bab"      yes  (length 3)
"aba"     "aba"      yes  (length 3)
"abad"    "daba"     no
"babad"   "dabab"    no
```

Two things to notice:

1. **A single letter is always a palindrome.** The answer is never empty.
2. **Palindromes come in two shapes.** Odd length with a middle letter (`"bab"` — middle is
   `a`), and even length with no middle letter (`"bb"` — the middle is *between* the two `b`s).
   Both must be handled. That's the small trap in this problem.

### The idea: stand on every middle and walk outwards

Every palindrome has a middle. Stand on a box, put a **left foot** and a **right foot** there,
and step them outwards together — one box left, one box right — as long as the two feet see
the same letter. The farthest they get before the letters stop matching is the palindrome
around that middle. Do this for every middle, keep the longest.

```
"babad", standing on box 2

         ┌───┬───┬───┬───┬───┐
         │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
           0   1   2   3   4

round 1:           L R            b == b  ✓   spread
round 2:       L       R          a == a  ✓   spread
round 3:   L               R      b == d  ✗   stop      →  "aba" is between the feet
```

The plan in one sentence:

> **For every box, walk two feet outwards (once with the feet together, once with them on
> neighbouring boxes) while the letters match. Measure what's between them. Keep the longest.**

The running example for every step below is `s = "babad"`.

---

## Step 2 — Turn the string into an array

```swift
let chars = Array(s)
```

A Swift `String` can't be indexed with a number — `s[2]` won't compile. `Array(s)` lays every
letter into its own numbered box, and `chars[2]` works.

```
s = "babad"           ← one string, can't say s[2]

            ↓ Array(s)

         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
```

The whole algorithm is "stand on a box, look at the box to the left, look at the box to the
right". You can only do that with numbered boxes.

---

## Step 3 — A bookmark for where the best palindrome starts

```swift
var bestStart = 0
```

We'll find several palindromes while scanning. At the end we must hand back the longest, so we
need to remember **which box it begins at**.

```
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
           ▲
       bestStart = 0
```

It starts at 0 because we haven't looked at anything yet, and the first box on its own is a
valid one-letter palindrome.

---

## Step 4 — A bookmark for how long it is

```swift
var bestLength = 1
```

The second half of the record: **how many boxes** the best palindrome covers.

```
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
           ▲
       bestStart = 0
       bestLength = 1     →  covers just  [ b ]
```

It starts at **1, not 0**, because one letter is always a palindrome. Even before the scan,
"box 0, one letter long" is a real answer. If the string were `"abc"` and nothing beat it,
we'd correctly return `"a"`.

---

## Step 5 — Stand on every box

```swift
for center in 0..<s.count {

}
```

Every palindrome has a middle. If we stand on every box and walk outwards from each, we are
guaranteed to bump into the longest one at some point — we never have to guess where it is.

```
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4

center = 0   ▲
center = 1       ▲
center = 2           ▲
center = 3               ▲
center = 4                   ▲
```

`0..<5` means 0, 1, 2, 3, 4 — every index, stopping *before* 5.

---

## Step 6 — Walk each middle twice, once per shape

```swift
for rightStart in [center, center + 1] {

}
```

### What the line literally does

`[center, center + 1]` is a list of two numbers. The `for` runs the body **twice**: first with
`rightStart = center`, then with `rightStart = center + 1`. When `center` is 1:

```
1st run:  rightStart = 1
2nd run:  rightStart = 2
```

`rightStart` is simply **the box where the right foot will begin**. The left foot always
begins on `center`.

```
center = 1

         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4

1st run:       L
               R          ← both feet on box 1       (odd shape)

2nd run:       L   R      ← left on 1, right on 2    (even shape)
```

### Why two runs — what goes wrong with one

Imagine only the 1st run, feet together. Watch `"cbbd"`:

```
         ┌───┬───┬───┬───┬───┐
chars:   │ c │ b │ b │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3

center = 1:   (1,1)  b == b  ✓  →  (0,2)  c == b  ✗  stop
center = 2:   (2,2)  b == b  ✓  →  (1,3)  b == d  ✗  stop
```

The feet were on (1,1), (0,2), (2,2), (1,3). **Never on (1,2)** — the two `b`s. Starting
together and spreading one each way, the feet are always an *even* number of boxes apart:
0, 2, 4… They can never be 1 apart. So `"bb"` is never found.

The 2nd run starts the feet on neighbours — 1 apart — and spreads: 1, 3, 5… That's where the
even palindromes live:

```
center = 1, rightStart = 2:   (1,2)  b == b  ✓  →  (0,3)  c == d  ✗  stop     →  "bb"
```

### The two shapes side by side

```
Odd-length palindrome        Even-length palindrome
"a b a"                      "b b"
   ▲                            ▲
 middle is a letter          middle is the gap between letters
 feet start TOGETHER         feet start on NEIGHBOURS
 rightStart = center         rightStart = center + 1
```

Every palindrome is one of these two shapes. Run 1 catches all the odd ones, run 2 all the
even ones. Same walking code both times — only the right foot's starting box changes.

### All ten starting positions on `"babad"`

```
center   run     left   right
  0      1st      0      0
  0      2nd      0      1
  1      1st      1      1
  1      2nd      1      2
  2      1st      2      2
  2      2nd      2      3
  3      1st      3      3
  3      2nd      3      4
  4      1st      4      4
  4      2nd      4      5   ← off the edge; handled safely in Step 9
```

---

## Step 7 — The left foot

```swift
var left = center
```

The left foot starts on the middle box.

```
center = 2

         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
                   L              left = 2
```

It's a `var` because it will move. It's declared *inside* the loops so that every new
`center` / `rightStart` pair gets a fresh foot back on the middle.

---

## Step 8 — The right foot

```swift
var right = rightStart
```

The right foot starts on whichever box Step 6 chose.

```
center = 2

1st run  (rightStart = 2):
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
                   L
                   R              left = 2, right = 2

2nd run  (rightStart = 3):
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
                   L   R          left = 2, right = 3
```

---

## Step 9 — The walking rule

```swift
while left >= 0 && right < chars.count && chars[left] == chars[right] {

}
```

Keep walking **while** all three are true:

| Check | Plain English |
|---|---|
| `left >= 0` | the left foot hasn't fallen off the front of the boxes |
| `right < chars.count` | the right foot hasn't fallen off the end |
| `chars[left] == chars[right]` | both feet see the same letter |

If any one fails, the walk stops.

```
center = 2, 1st run

         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
                   L
                   R

check 1:  2 >= 0        ✓
check 2:  2 < 5         ✓
check 3:  b == b        ✓      →  all true, enter the loop
```

### Why the two boundary checks come first

Swift stops reading at the first `false`. If the left foot has fallen off to `-1`, check 1
fails and Swift **never reaches** `chars[-1]`, which would crash. Put the letter comparison
first and it *would* crash. The order is not cosmetic.

### The `<=` trap

Writing `right <= chars.count` instead of `<` crashes with *Index out of range*. With
`chars.count = 5` the valid boxes are 0–4; `5 <= 5` is true, so Swift goes on to read
`chars[5]`, which doesn't exist. `5 < 5` is false and stops the walk in time.

---

## Step 10 — Step the left foot out

```swift
left -= 1
```

The letters matched, so the left foot steps one box to the left.

```
center = 2, 1st run

before:            L
                   R

after:         L   R              left = 1, right still 2
```

The right foot hasn't moved yet — that's the next line. The two lines together make one
"spread".

---

## Step 11 — Step the right foot out

```swift
right += 1
```

Now the spread is complete and the `while` checks again. The full walk for `center = 2`:

```
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4

round 1:           L R            b == b  ✓   →  spread
round 2:       L       R          a == a  ✓   →  spread
round 3:   L               R      b == d  ✗   →  stop

ends with:  left = 0, right = 4
```

**Look where the feet stopped.** They're standing on the two letters that **broke** the match
— `b` at 0 and `d` at 4. The palindrome is the part *between* them:

```
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
           L  [ a   b   a ] R
                palindrome
```

The feet always overshoot by one box on each side. The next three lines rely on that.

---

## Step 12 — Measure what's between the feet

```swift
let currentLength = right - left - 1
```

```
center = 2, 1st run, walk ended with left = 0, right = 4

           L  [ a   b   a ] R

right - left      =  4 - 0  =  4      ← the gap, but one box too many
right - left - 1  =  3                ← "aba" = 3 boxes  ✓
```

`right - left` is the distance between the feet, but the boxes strictly *between* them number
one fewer. Think fence posts: posts at 0 and 4 have three boxes between them (1, 2, 3).

It still works when a foot fell off the edge — `center = 0`, 1st run:

```
round 1:   L R           b == b  ✓  →  spread
round 2:  L    R         left = -1, check 1 fails  →  stop

       L  [ b ] R                  left = -1, right = 1

right - left - 1  =  1 - (-1) - 1  =  1     ← "b" = 1 box  ✓
```

---

## Step 13 — Did it beat the record?

```swift
if currentLength > bestLength {

}
```

Only a **longer** palindrome replaces the record.

```
center = 2, 1st run

currentLength = 3       ← "aba", just measured
bestLength    = 1       ← "b", the record so far

         3 > 1 ?   yes  →  update the record
```

A case where it says no — `center = 3`, 1st run:

```
round 1:               L R        a == a  ✓  →  spread
round 2:           L       R      b == d  ✗  →  stop     left = 2, right = 4

currentLength = 4 - 2 - 1 = 1     ← just "a"
         1 > 3 ?   no   →  skip
```

It's `>` and not `>=`: a tie doesn't need to replace the record. Either answer is accepted.

---

## Step 14 — Record the new length

```swift
bestLength = currentLength
```

```
center = 2, 1st run

before:   bestLength = 1
after:    bestLength = 3
```

The record is now **half-updated** — the winner is 3 long, but `bestStart` still points at
box 0. If we stopped here we'd return `"bab"` by accident: right length, wrong spot. The next
line fixes the start.

---

## Step 15 — Record where it starts

```swift
bestStart = left + 1
```

The left foot overshot — it's on the letter that *broke* the match. The palindrome starts one
box to its right.

```
center = 2, 1st run, walk ended with left = 0

         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4
           L   ▲
               left + 1 = 1       ← "aba" starts here

bestStart  = 1
bestLength = 3
```

Now both bookmarks agree: **start at box 1, take 3 boxes** → `a b a`.

### The flipped-assignment trap

`left = bestStart + 1` compiles fine and is wrong. It moves the *foot* instead of the
*bookmark*, so `bestStart` stays at 0 forever — right length, always from box 0. `"cbbd"` would
return `"cb"`. Remember it as: **the bookmark takes its value from the foot** — bookmark on the
left of the `=`, foot on the right.

---

## Step 16 — Hand back the winner

```swift
return String(chars[bestStart..<bestStart + bestLength])
```

Read it inside-out:

```
bestStart                           = 1
bestStart + bestLength              = 1 + 3 = 4
bestStart..<bestStart + bestLength  = 1..<4  = boxes 1, 2, 3   (..< stops before 4)

chars[1..<4]                        = [ a, b, a ]     ← a slice of the array
String( [ a, b, a ] )               = "aba"           ← back to a String
```

`chars[1..<4]` is an array slice, not a string. The function promises a `String`, so we wrap it.

---

## Step 17 — Watch it run on the examples

### `"babad"` → `"bab"`

```
         ┌───┬───┬───┬───┬───┐
chars:   │ b │ a │ b │ a │ d │
         └───┴───┴───┴───┴───┘
index:     0   1   2   3   4

start: bestStart = 0, bestLength = 1
```

| center | rightStart | walk (left,right → stop reason) | length | record after |
|---|---|---|---|---|
| 0 | 0 | (0,0) b=b → (-1,1) left off edge | 1 | 1 > 1? no |
| 0 | 1 | (0,1) b≠a stop | 0 | no |
| 1 | 1 | (1,1) a=a → (0,2) b=b → (-1,3) off edge | **3** | **yes → bestStart 0, bestLength 3** |
| 1 | 2 | (1,2) a≠b stop | 0 | no |
| 2 | 2 | (2,2) b=b → (1,3) a=a → (0,4) b≠d stop | 3 | 3 > 3? no (tie) |
| 2 | 3 | (2,3) b≠a stop | 0 | no |
| 3 | 3 | (3,3) a=a → (2,4) b≠d stop | 1 | no |
| 3 | 4 | (3,4) a≠d stop | 0 | no |
| 4 | 4 | (4,4) d=d → (3,5) right off edge | 1 | no |
| 4 | 5 | right = 5, check 2 fails, loop never runs | 0 | no |

```
return chars[0..<3]  →  b, a, b  →  "bab"
```

`"bab"` is found first (at `center = 1`). `"aba"` at `center = 2` is a tie, so the record
doesn't change. Either is accepted. ✓

### `"cbbd"` → `"bb"`

| center | rightStart | walk | length | record after |
|---|---|---|---|---|
| 0 | 0 | (0,0) c=c → (-1,1) off edge | 1 | no |
| 0 | 1 | (0,1) c≠b stop | 0 | no |
| 1 | 1 | (1,1) b=b → (0,2) c≠b stop | 1 | no |
| 1 | 2 | (1,2) b=b → (0,3) c≠d stop | **2** | **yes → bestStart 1, bestLength 2** |
| 2 | 2 | (2,2) b=b → (1,3) b≠d stop | 1 | no |
| 2 | 3 | (2,3) b≠d stop | 0 | no |
| 3 | 3 | (3,3) d=d → (2,4) right off edge | 1 | no |
| 3 | 4 | right = 4, loop never runs | 0 | no |

```
return chars[1..<3]  →  b, b  →  "bb"
```

The only row that finds it is the **2nd run** at `center = 1` — the even shape. ✓

### The last-box safety check

When `center = 3` on `"cbbd"`, the 2nd run sets `rightStart = 4`, which is off the end. It
doesn't crash: check 2 (`4 < 4`) is false, the walk never starts, `chars[4]` is never read.
Length comes out `4 - 3 - 1 = 0`, which never beats the record.

---

## The finished solution

```swift
class Solution {
    func longestPalindrome(_ s: String) -> String {
        
        let chars = Array(s)
        var bestStart = 0
        var bestLength = 1

        for center in 0..<s.count {
            for rightStart in [center, center + 1] {
                var left = center
                var right = rightStart

                while left >= 0 && right < chars.count && chars[left] == chars[right] {
                    left -= 1
                    right += 1
                }

                let currentLength = right - left - 1
                if currentLength > bestLength {
                    bestLength = currentLength
                    bestStart = left + 1
                }
            }
        }

        return String(chars[bestStart..<bestStart + bestLength])
    }
}
```

---

## Questions an interviewer will ask

| Question | Answer |
|---|---|
| What's the brute force? | Check every substring, reverse it, compare. About n² substrings × n to reverse = O(n³). ~1 billion steps at n = 1000. |
| Why expand from the centre? | Every palindrome has a middle. Growing outwards from each middle finds the longest one around it in a single pass, with no reversing. |
| Why walk each centre twice? | Odd palindromes have a middle letter; even ones have a middle *gap*. Feet starting together are always an even distance apart and can never see `"bb"`. |
| Why `right - left - 1` and `left + 1`? | The walk stops with both feet on the letters that broke the match, one box outside the palindrome on each side. |
| Why is the boundary check before the letter comparison? | `&&` short-circuits. If a foot is at `-1` or `count`, Swift never evaluates `chars[...]`, so it never reads out of range. |
| Why `bestLength = 1` and not 0? | One letter is always a palindrome. It gives a correct fallback and means the record only ever holds a real palindrome. |
| Is there a faster algorithm? | Yes — Manacher's is O(n). It's rarely expected; say it exists, then write expand-around-centre. |
| What about DP? | `isPalindrome[i][j]` table. Same O(n²) time but O(n²) space — strictly worse than this. |

**The three phrases that rebuild this from scratch:**

> **stand on every box (twice: feet together, feet on neighbours) → walk out while the letters match → measure between the feet, keep the longest**

---

## Time and Space Complexity

### Time — O(n²)

`n` is the length of the string.

| What we do | Cost |
|---|---|
| Outer loop: every `center` | `n` |
| Inner loop: two shapes per centre | × 2 |
| The walk from one centre | at most `n / 2` spreads |
| Everything after the walk | O(1) |

`n × 2 × n/2 = n²`. The worst case is a string like `"aaaa…a"` where every walk runs all the
way to the edge. At `n = 1000` that's about 1 million foot-steps — instant.

`Array(s)` at the top is one O(n) pass. It doesn't change the total.

### Space — O(n)

The `chars` array is a copy of the string. Everything else — `bestStart`, `bestLength`,
`center`, `rightStart`, `left`, `right`, `currentLength` — is a fixed handful of integers.

The array is a Swift indexing convenience, not part of the algorithm. In a language with integer
string indices the algorithm itself is **O(1)** extra space.

### Can it be beaten?

**Yes, on paper.** Manacher's algorithm reuses work from mirrored centres to get **O(n)**. It's
about 30 lines of tricky mirror-index arithmetic and is almost never asked for in interviews.
With `n ≤ 1000` the difference is invisible. Expand-around-centre is the answer interviewers
expect; mentioning Manacher's by name is the bonus.
