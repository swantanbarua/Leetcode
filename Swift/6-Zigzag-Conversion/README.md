# 6. Zigzag Conversion

**Difficulty:** Medium · **Status:** Accepted · [Problem link](https://leetcode.com/problems/zigzag-conversion/)

> The string `"PAYPALISHIRING"` is written in a zigzag pattern on a given number of rows, then
> read line by line. Write the code that takes a string and a number of rows and makes this
> conversion.

**Examples**

```
s = "PAYPALISHIRING", numRows = 3   →   "PAHNAPLSIIGYIR"
s = "PAYPALISHIRING", numRows = 4   →   "PINALSIGYAHRPI"
s = "A",              numRows = 1   →   "A"
```

**Constraints**

- `1 <= s.length <= 1000`
- `s` consists of English letters (lower-case and upper-case), `','` and `'.'`.
- `1 <= numRows <= 1000`

---

## Step 1 — What are we actually being asked?

You get a word and a number of rows. Write the word out in a zigzag, then read it back row by
row.

**How you write it.** Letters go **straight down**, then **diagonally back up**, then down
again, and so on:

```
Letter order:  P A Y P A L I S H I R I N G

  P       A       H       N        ← row 0
  A   P   L   S   I   I   G        ← row 1
  Y       I       R                ← row 2

  ↓   ↗   ↓   ↗   ↓   ↗   ↓
```

- P, A, Y go **down** (rows 0, 1, 2).
- P goes **up diagonally** into row 1.
- A, L, I go down again. S goes up. And so on.

**How you read it.** Each row left to right, top row first, joined together:

```
row 0:  P A H N         →  "PAHN"
row 1:  A P L S I I G   →  "APLSIIG"
row 2:  Y I R           →  "YIR"

answer: "PAHN" + "APLSIIG" + "YIR" = "PAHNAPLSIIGYIR"
```

### The whole pattern is one bouncing number

Write down which row each letter lands on:

```
letter:  P  A  Y  P  A  L  I  S  H  I  R  I  N  G
row:     0  1  2  1  0  1  2  1  0  1  2  1  0  1
```

The row goes 0 → 1 → 2 → 1 → 0 → 1 → 2 … It **bounces** between the top row and the bottom
row, like a ball. With 4 rows the bounce goes deeper (0 → 1 → 2 → 3 → 2 → 1 → 0 …). With 1 row
there's nowhere to bounce and the word comes back unchanged.

The spaces in the drawing are only decoration. The real job is:

> **For each letter, work out which row it belongs to. Put the rows together at the end.**

### The idea: one shelf per row

Keep one empty "shelf" for every row. Walk through the letters, drop each one on the shelf
you're standing at, then step one shelf down or up. When you hit the top or the bottom, turn
around. At the end, read the shelves top to bottom.

The running example for every step below is `s = "PAYPALISHIRING"`, `numRows = 3`.

---

## Step 2 — One empty shelf per row

```swift
var rows = Array(repeating: "", count: numRows)
```

This makes a list of empty strings, one for each row of the zigzag.

```
index:   0     1     2
       ┌────┬────┬────┐
rows:  │ "" │ "" │ "" │
       └────┴────┴────┘
       top  middle bottom
```

By the end, the shelves will hold exactly the three rows you read off in Step 1:

```
       ┌────────┬───────────┬───────┐
rows:  │ "PAHN" │ "APLSIIG" │ "YIR" │
       └────────┴───────────┴───────┘
```

Each letter is **appended** to the end of one shelf, so letters on the same shelf stay in the
order they arrived — which is exactly the left-to-right order of that row in the drawing.

---

## Step 3 — Which shelf are we standing at?

```swift
var currentRow = 0
```

A pointer to the shelf we're at right now. We start at the top, row 0, because the zigzag
always begins in the top-left corner.

```
index:        0     1     2
            ┌────┬────┬────┐
rows:       │ "" │ "" │ "" │
            └────┴────┴────┘
              ▲
          currentRow = 0
```

Over the whole word, `currentRow` will take exactly the bouncing values from Step 1:

```
letter:      P  A  Y  P  A  L  I  S  H  I  R  I  N  G
currentRow:  0  1  2  1  0  1  2  1  0  1  2  1  0  1
```

---

## Step 4 — Which way are we heading?

```swift
var goingDown = false
```

`true` means heading down to the next row, `false` means heading back up.

**"We start by going down — so why `false`?"** Because of the turn-around rule in Step 7:
whenever we land on the **top** or **bottom** row, the direction flips. The very first letter
lands on row 0, the top, so a flip happens immediately:

```
start:                       goingDown = false
place P on row 0 → top → flip → goingDown = true
move down                    → row 1
```

`false`, flipped once, becomes `true`, so the first real move is down. Start at `true` and that
first flip turns it to `false` — the first move goes **up** from row 0 to row -1, which
doesn't exist (Step 7 shows it).

---

## Step 5 — Visit every letter

```swift
for character in s {

}
```

Walks the word left to right, one letter at a time.

```
s:          P  A  Y  P  A  L  I  S  H  I  R  I  N  G
            ▲
         character (1st time round) = "P"
```

The loop body does three things for every letter:

1. put the letter on the current shelf
2. flip direction if we're at the top or the bottom
3. move one row up or down

---

## Step 6 — Drop the letter on the current shelf

```swift
rows[currentRow].append(character)
```

```
character = "P",  currentRow = 0

index:        0      1     2
            ┌─────┬────┬────┐
rows:       │ "P" │ "" │ "" │
            └─────┴────┴────┘
              ▲
          currentRow = 0
```

**On its own this isn't enough.** Nothing changes `currentRow` yet, so every letter lands on
the top shelf:

```
after all 14 letters:

            ┌──────────────────┬────┬────┐
rows:       │ "PAYPALISHIRING" │ "" │ "" │
            └──────────────────┴────┴────┘
```

That's the original word, not a zigzag. The next two steps make `currentRow` move.

---

## Step 7 — Turn around at the top and the bottom

```swift
if currentRow == 0 || currentRow == numRows - 1 { goingDown.toggle() }
```

If we're on the **top** row (`0`) or the **bottom** row (`numRows - 1`), flip the direction.
`toggle()` turns `true` into `false` and `false` into `true`.

**Why `numRows - 1`?** Rows are counted from 0. With 3 rows the indexes are 0, 1, 2, so the
bottom row is 2, which is 3 - 1.

```
letter  currentRow  at an edge?   goingDown after
  P         0        yes (top)    false → true    ↓ start going down
  A         1        no           true
  Y         2        yes (bottom) true → false    ↑ turn around
  P         1        no           false
  A         0        yes (top)    false → true    ↓ turn around
```

The middle row never flips anything. It gets passed through on the way down **and** on the
way up, which is why it collects the most letters.

**The wrong starting direction, shown.** With `var goingDown = true`:

```
  P         0        yes (top)    true → false    ↑ go UP from row 0
                                                    → row -1 → crash: index out of range
```

---

## Step 8 — Take one step

```swift
currentRow += goingDown ? 1 : -1
```

If `goingDown` is `true`, add 1 (move down a row). If `false`, add -1 (move up a row).
`condition ? a : b` means "if true use `a`, otherwise use `b`".

### Full trace on `"PAYPALISHIRING"`, `numRows = 3`

```
letter  row  shelves after placing               edge? → goingDown  next row
  P      0   ["P",    "",        ""   ]          top    → true        1
  A      1   ["P",    "A",       ""   ]                   true        2
  Y      2   ["P",    "A",       "Y"  ]          bottom → false       1
  P      1   ["P",    "AP",      "Y"  ]                   false       0
  A      0   ["PA",   "AP",      "Y"  ]          top    → true        1
  L      1   ["PA",   "APL",     "Y"  ]                   true        2
  I      2   ["PA",   "APL",     "YI" ]          bottom → false       1
  S      1   ["PA",   "APLS",    "YI" ]                   false       0
  H      0   ["PAH",  "APLS",    "YI" ]          top    → true        1
  I      1   ["PAH",  "APLSI",   "YI" ]                   true        2
  R      2   ["PAH",  "APLSI",   "YIR"]          bottom → false       1
  I      1   ["PAH",  "APLSII",  "YIR"]                   false       0
  N      0   ["PAHN", "APLSII",  "YIR"]          top    → true        1
  G      1   ["PAHN", "APLSIIG", "YIR"]                   true        2
```

After the loop, the shelves are exactly the three rows of the zigzag:

```
            ┌────────┬───────────┬───────┐
rows:       │ "PAHN" │ "APLSIIG" │ "YIR" │
            └────────┴───────────┴───────┘
```

(The last "next row = 2" is never used — the loop has run out of letters.)

---

## Step 9 — Glue the shelves together

```swift
return rows.joined()
```

`joined()` sticks the strings together first to last, with nothing in between.

```
rows:     "PAHN"  +  "APLSIIG"  +  "YIR"

joined:   "PAHNAPLSIIGYIR"   ✅  Example 1
```

---

## Step 10 — The one-row trap

```swift
if numRows == 1 { return s }
```

This goes at the very **top** of the function. Without it, look what happens with one row.
Row 0 is the top **and** the bottom (`numRows - 1 = 0`), so the direction flips on every
letter and `currentRow` walks off the end:

```
s = "AB", numRows = 1, WITHOUT the guard

letter  row  edge?                    goingDown  next row
  A      0   top (0 == 0) → flip       true       1       ← row 1 doesn't exist
  B      1   rows[1]  →  💥 crash: index out of range (there is only rows[0])
```

(`"A"` alone survives only because the loop ends before the bad row is used.)

With one row, the zigzag is the word written in a straight line, so reading it back gives the
same word. Return it unchanged, before any shelf is touched:

```
s = "AB", numRows = 1  →  return "AB"   ✅
s = "A",  numRows = 1  →  return "A"    ✅  Example 3
```

---

## Step 11 — Watch it run on Example 2

`s = "PAYPALISHIRING"`, `numRows = 4`. Edges are now row 0 and row 3, so the bounce is
0 → 1 → 2 → 3 → 2 → 1 → 0:

```
letter:  P  A  Y  P  A  L  I  S  H  I  R  I  N  G
row:     0  1  2  3  2  1  0  1  2  3  2  1  0  1
```

| letter | row | edge? | shelves after |
|---|---|---|---|
| P | 0 | top → down | `P`, `""`, `""`, `""` |
| A | 1 | | `P`, `A`, `""`, `""` |
| Y | 2 | | `P`, `A`, `Y`, `""` |
| P | 3 | bottom → up | `P`, `A`, `Y`, `P` |
| A | 2 | | `P`, `A`, `YA`, `P` |
| L | 1 | | `P`, `AL`, `YA`, `P` |
| I | 0 | top → down | `PI`, `AL`, `YA`, `P` |
| S | 1 | | `PI`, `ALS`, `YA`, `P` |
| H | 2 | | `PI`, `ALS`, `YAH`, `P` |
| I | 3 | bottom → up | `PI`, `ALS`, `YAH`, `PI` |
| R | 2 | | `PI`, `ALS`, `YAHR`, `PI` |
| I | 1 | | `PI`, `ALSI`, `YAHR`, `PI` |
| N | 0 | top → down | `PIN`, `ALSI`, `YAHR`, `PI` |
| G | 1 | | `PIN`, `ALSIG`, `YAHR`, `PI` |

```
"PIN" + "ALSIG" + "YAHR" + "PI"  =  "PINALSIGYAHRPI"   ✅
```

---

## The finished solution

```swift
class Solution {
    func convert(_ s: String, _ numRows: Int) -> String {
        
        if numRows == 1 { return s }

        var rows = Array(
            repeating: "",
            count: numRows
        )
        var currentRow = 0
        var goingDown = false

        for character in s {
            rows[currentRow].append(character)

            if currentRow == 0 || currentRow == numRows - 1 { goingDown.toggle() }
            currentRow += goingDown ? 1 : -1
        }

        return rows.joined()
    }
}
```

---

## Questions an interviewer will ask

| Question | Answer |
|---|---|
| Do you need to build the 2-D grid with spaces? | No. Only the order of letters inside each row matters, so one string per row is enough. A full grid wastes `numRows × columns` space for nothing. |
| Why does `goingDown` start as `false`? | The first letter lands on row 0, which flips the direction before the first move. `false` flipped becomes `true` → the first move is down. |
| Why the `numRows == 1` guard? | With one row, top and bottom are the same row, so the direction flips every letter and `currentRow` goes to 1 → index out of range. One row means the word is unchanged anyway. |
| What if `numRows >= s.count`? | Every letter gets its own row going straight down and the walk never turns around. The answer is `s` unchanged. The code already handles it correctly; some people add it to the guard as a shortcut. |
| Can you do it without simulating the walk? | Yes. The pattern repeats every `cycle = 2 × numRows - 2` letters. Row 0 and the last row take one letter per cycle (`k`, `k + cycle`, …). Each middle row `r` takes two per cycle: index `k + r` and `k + cycle - r`. Loop over rows and jump straight to those indexes. Same O(n) time, O(1) extra space beyond the output. |
| Is `Array(s)` needed here? | No. We only walk the string front to back with `for character in s`, which Swift does fine. Integer indexing is only needed in the cycle-maths version. |

**The phrase that rebuilds this from scratch:**

> **one shelf per row → drop each letter on the current shelf → flip at the top and bottom → step up or down → glue the shelves**

---

## Time and Space Complexity

### Time — O(n)

`n` is the length of the string.

| What we do | Cost |
|---|---|
| Make `numRows` empty shelves | O(numRows), and `numRows` is at most `n` whenever it matters |
| Visit every letter once | `n` |
| Per letter: append, one `if`, one addition | O(1) (appending to a Swift `String` is amortised O(1)) |
| `joined()` at the end | touches every letter once more → `n` |

Total: `n + n = O(n)`. At `n = 1000` that's about 2,000 operations — instant.

### Space — O(n)

The shelves hold every letter exactly once, so together they're the size of the input. The
answer string is another `n`, but the output usually isn't counted. Everything else —
`currentRow`, `goingDown` — is a fixed pair of variables.

### Can it be beaten?

**Not on time.** Every letter has to appear in the answer, so any solution must at least read
every letter once — O(n) is the floor.

**On space, slightly.** The cycle-maths version from the interview table writes letters
straight into the answer without any shelves, so its extra space is **O(1)** beyond the output.
The shelf version is easier to explain and is what most interviewers expect first; mention the
cycle version as the follow-up.
