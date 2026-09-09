# 1. Two Sum

**Difficulty:** Easy · **Status:** Accepted · [Problem link](https://leetcode.com/problems/two-sum/)

> You are given an array of integers `nums` and an integer `target`, return **indices** of the
> two numbers such that they add up to `target`.
>
> You may assume that each input would have **exactly one solution**, and you may not use the
> *same element* twice. You can return the answer in any order.

**Examples**

```
nums = [2,7,11,15], target = 9   →   [0,1]      because nums[0] + nums[1] == 9
nums = [3,2,4],     target = 6   →   [1,2]
nums = [3,3],       target = 6   →   [0,1]
```

---

## Step 1 — What are we actually looking for?

You have some numbers:

```
nums = [2, 7, 11, 15]      target = 9
```

You need **two numbers from this list that add up to 9.**

### The slow way of thinking

*"Let me try every possible pair and see which one adds to 9."*

```
2 + 7  = 9   ✓ found it
2 + 11 = 13
2 + 15 = 17
7 + 11 = 18
...
```

This works. But if the list had 10,000 numbers, that's about 50 million pairs to check. Too slow.

### The smart way of thinking

Instead of testing pairs, **pick up one number at a time and ask: what's my missing piece?**

Say you pick up the **7**. The two numbers must add to **9**. So:

```
7 + ? = 9
```

There is only ONE possible answer to that: **2**.

Not "something small". Not "some number that might work". Exactly **2**. And you can
calculate it instantly:

```
missing piece = 9 - 7 = 2
```

That's the whole trick.

| I pick up | I need |
|---|---|
| 2 | 9 − 2 = **7** |
| 7 | 9 − 7 = **2** |
| 11 | 9 − 11 = **−2** |
| 15 | 9 − 15 = **−6** |

Think of it like paying a ₹9 bill. If you hand over a ₹7 note, you know instantly you need
exactly ₹2 more. You don't try every note in your wallet — you know the number.

### Why this matters

The question just got much easier:

- **Before:** "Which two numbers add to 9?" → I have to try combinations.
- **Now:** "I need a 2. Have I seen a 2 anywhere?" → I just have to *check* for one thing.

Checking for one thing is far faster than trying every combination.

> This missing piece has a proper name: the **complement**. Same idea, fancier word.

---

## Step 2 — Where do I keep the numbers I've already seen?

The plan is now: walk through the list, and at each number check *have I seen its missing
piece already?* So you need somewhere to **write down the numbers you've walked past**.

### What should we write down?

The problem does **not** want the numbers. It wants their **positions**.

```
nums = [2, 7, 11, 15]      target = 9
Answer = [0, 1]        ← positions, NOT [2, 7]
```

So when you write down a number, you must also write down **where you found it**:

```
I saw the number 2  ...at position 0
I saw the number 7  ...at position 1
```

### What kind of "notebook"?

**A plain list?** To check "have I seen a 2?" you'd read the whole list top to bottom.
Slow — which is exactly what we're escaping.

**A dictionary.** This is the one. A Swift dictionary is a lookup table — think of the index
at the back of a textbook:

```
"gravity"  →  page 42
"magnets"  →  page 87
```

You don't read the whole index. You jump straight to the word and it tells you the page.
**Instant.** Exactly what we need:

```
number 2   →  position 0
number 7   →  position 1
```

### Which side is which?

The rule:

- The thing you **search by** goes on the left (the key).
- The thing you **want back** goes on the right (the value).

You search by number, you want the position. So `number → position`. Not the other way around.

### The code

```swift
var seen: [Int : Int] = [:]
```

| Part | Meaning |
|---|---|
| `var` | It can change — we keep adding to it |
| `seen` | The name. It holds numbers we have *seen* |
| `[Int : Int]` | A dictionary: key is an `Int` (the number), value is an `Int` (the position) |
| `= [:]` | Start it **empty** |

Two things worth knowing:

- `[:]` is an empty **dictionary**. `[]` is an empty **array**. The colon is what makes the
  difference — don't lose it.
- It must be `var`, not `let`. `let` means "never changes", and we'll be adding to this constantly.

---

## Step 3 — Walking through the list

At every stop we need **two** things:

```
nums = [2, 7, 11, 15]

stop 1 → the number 2,   at position 0
stop 2 → the number 7,   at position 1
stop 3 → the number 11,  at position 2
stop 4 → the number 15,  at position 3
```

### The plain way (works, but clunky)

```swift
for i in 0..<nums.count {
    let num = nums[i]
}
```

`0..<nums.count` means "from 0, up to but **not including** the count". For 4 numbers that's
0, 1, 2, 3 — correct, because positions start at 0, so the last one is 3.

It works, but you're doing two jobs: counting, then reaching back into the array.

### The Swift way

```swift
for (index, num) in nums.enumerated() {

}
```

`enumerated()` means "number them for me". It hands you the position **and** the value together:

```
(0, 2)
(1, 7)
(2, 11)
(3, 15)
```

Those pairs are **tuples** — two values travelling together in one package. And
`for (index, num) in` **unpacks** that package into two names as it arrives:

```
package (1, 7)  →  index = 1     num = 7
```

So inside the loop you just have `index` and `num` ready to use.

> `index` and `num` are names *you* chose. `for (position, value) in` would work identically.

---

## Step 4 — Work out the missing piece

Step 1's idea, finally as code. One line:

```swift
for (index, num) in nums.enumerated() {
    let diff = target - num
}
```

At every stop, subtract the number you're holding from the target, and you have the number
you're missing.

`nums = [2, 7, 11, 15]`, `target = 9`:

| stop | `index` | `num` | `diff` = `target - num` |
|---|---|---|---|
| 1 | 0 | 2 | 9 − 2 = **7** |
| 2 | 1 | 7 | 9 − 7 = **2** |
| 3 | 2 | 11 | 9 − 11 = **−2** |
| 4 | 3 | 15 | 9 − 15 = **−6** |

Small things worth noticing:

- **`let`, not `var`.** It's calculated once per stop and never changed. In Swift, use `let`
  unless you actually need to change something.
- **Negative results are fine.** At stop 3 the missing piece is −2. Not a bug — it just means
  "if a −2 existed here, it would pair with 11". There isn't one, so nothing matches and we
  move on. Subtraction doesn't care about signs.

---

## Step 5 — Check the notebook

We know what we're missing. Now go look for it.

```swift
if let diffIndex = seen[diff] {
    return [diffIndex, index]
}
```

In plain English:

> *"Have I written down a `diff` in my notebook? If yes, tell me what position it was at —
> that position plus my current position is the answer."*

### Why `if let` and not a normal check

Looking something up in a dictionary **might find nothing.**

```swift
seen[7]     // maybe a position... or maybe nothing at all
```

Swift takes this seriously. It doesn't hand you a number — it hands you a **box** that either
has a number inside or is empty. That box is called an **Optional**.

So you can't use the result directly. You must open the box and check. `if let` is how:

```swift
if let diffIndex = seen[diff] {
    // reached ONLY if the box had something in it
    // and that something is now called diffIndex
}
```

Read it as: **"if there's something in there, pull it out, call it `diffIndex`, and run this block."**
If the box is empty, the block is skipped and the loop carries on — exactly the "not found,
keep walking" behaviour we want. One expression, two jobs: *checking* and *unpacking*.

### ⚠️ Do not do this

```swift
let diffIndex = seen[diff]!    // the ! means "trust me, it's there"
```

`!` forces the box open. If it's empty, **your program crashes.** And here the box is empty
*most of the time* — you only find a match once in the whole run. Never use `!` on a
dictionary lookup.

### What we return

```swift
return [diffIndex, index]
```

- `diffIndex` — where the missing piece was found (seen earlier)
- `index` — where you're standing right now

The problem says any order is fine, but putting the earlier one first matches the examples.

And `return` exits **immediately**. The moment we find the pair we stop — the problem promised
there's only one answer, so there's nothing left to look for.

---

## Step 6 — Write it in the notebook (and *where* you write it matters)

```swift
seen[num] = index
```

*"I saw the number `num`, at position `index`. Write that down."*

Walking `[2, 7, 11, 15]`, the notebook fills up:

```
after stop 1:  [2: 0]
after stop 2:  [2: 0, 7: 1]
after stop 3:  [2: 0, 7: 1, 11: 2]
```

> In Swift there's no "add" method — you assign with square brackets. `seen[num] = index`
> inserts if new, overwrites if that number was already there.

### Now: where exactly does this line go?

Two options, and **this is the most important decision in the whole problem.**

**Option A — write first, then check:**

```swift
seen[num] = index                                  // write
if let j = seen[diff] { return [j, index] }        // then check
```

**Option B — check first, then write:**

```swift
if let j = seen[diff] { return [j, index] }        // check
seen[num] = index                                  // then write
```

Both compile. Both run. **Option A is wrong.**

### Why Option A breaks

Take `nums = [3, 4]`, `target = 6`. Standing on the 3 at position 0:

1. Write it down → notebook is `[3: 0]`
2. Missing piece = 6 − 3 = **3**
3. Check for a 3 → **found one!** At position 0.
4. Return `[0, 0]`

You just found **yourself**. The answer says "use position 0, twice" — but the problem said
*you may not use the same element twice.*

Actually running that broken version:

```
[3, 4]  target 6  →  [0, 0]      ✗ wrong
[3, 3]  target 6  →  [0, 0]      ✗ wrong (should be [0, 1])
```

### Why Option B works

Check **before** you write, and your notebook only ever contains numbers from **behind you** —
never the one you're standing on.

Same input `[3, 4]`, target 6:

1. Missing piece = 3
2. Check the notebook → **empty**, nothing found ✓
3. *Now* write down `3 → 0`
4. Move on

You couldn't find yourself, because you hadn't written yourself down yet.

Notice what you did **not** have to write: any code saying *"make sure these two positions are
different."* The ordering handles it for free.

### But what about `[3, 3]`?

The case people worry about. `nums = [3, 3]`, `target = 6`, correct answer `[0, 1]`:

| stop | position | number | missing piece | notebook | found? | do |
|---|---|---|---|---|---|---|
| 1 | 0 | 3 | 3 | *empty* | no | write `3 → 0` |
| 2 | 1 | 3 | 3 | `[3: 0]` | **yes → 0** | return `[0, 1]` ✓ |

Works perfectly. And that's the rule the problem is really testing:

> **Two positions holding the same value → allowed.**
> **The same position used twice → not allowed.**

The first 3 and the second 3 are *different elements* that happen to look alike. Checking
before writing gets both cases right at once.

---

## Step 7 — Watch it run, line by line

`nums = [3, 2, 4]`, `target = 6`. Correct answer is `[1, 2]`, because `2 + 4 = 6`.

**Before the loop:** `seen = [:]` — empty notebook.

### Stop 1 — position 0, number 3

```swift
let diff = target - num           // 6 - 3 = 3
```
*"I'm holding a 3. I need another 3."*

```swift
if let diffIndex = seen[diff] {
```
*"Is there a 3 in my notebook?"* — it's **empty**. Nothing found. Skip the block.

```swift
seen[num] = index                 // seen[3] = 0
```

```
seen = [3: 0]
```

**Key moment:** we were holding a 3 and looking for a 3 — and did **not** match ourselves,
because we hadn't written ourselves down yet. That's Step 6 protecting us.

### Stop 2 — position 1, number 2

```swift
let diff = target - num           // 6 - 2 = 4
```
*"I'm holding a 2. I need a 4."* Notebook has only `[3: 0]`. No 4. Skip.

```swift
seen[num] = index                 // seen[2] = 1
```

```
seen = [3: 0, 2: 1]
```

### Stop 3 — position 2, number 4

```swift
let diff = target - num           // 6 - 4 = 2
```
*"I'm holding a 4. I need a 2."*

```swift
if let diffIndex = seen[diff] {
```
**Yes!** `2 → 1`. So `diffIndex = 1`.

```swift
return [diffIndex, index]         // return [1, 2]
```

Done. Check it: `nums[1] = 2`, `nums[2] = 4`, and `2 + 4 = 6`. ✓

### The same thing as one table

| stop | position | number | need | notebook when I look | found? | what I do |
|---|---|---|---|---|---|---|
| 1 | 0 | 3 | 3 | `[:]` | no | write `3 → 0` |
| 2 | 1 | 2 | 4 | `[3:0]` | no | write `2 → 1` |
| 3 | 2 | 4 | 2 | `[3:0, 2:1]` | **yes, at 1** | return `[1, 2]` |

### One loose end: the last line

```swift
return [-1, -1]
```

We never reached it — we returned from inside the loop. So why is it there?

Because **Swift won't compile without it.** The signature promises to return `[Int]`. Swift
checks *every possible path* and asks "does this one return something?" If the loop finished
without a match there'd be no return at all, and Swift refuses to allow that.

So it exists purely to satisfy the compiler. The problem guarantees a solution, so it never runs.
`return []` works identically; `[-1, -1]` is arguably a better habit, since `-1` is the
conventional "not found" marker — an obviously invalid index rather than an empty array a
caller might forget to check.

---

## The finished solution

```swift
class Solution {
    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {

        var seen: [Int : Int] = [:]

        for (index, num) in nums.enumerated() {
            let diff = target - num

            if let diffIndex = seen[diff] {
                return [diffIndex, index]
            }

            seen[num] = index
        }

        return [-1, -1]
    }
}
```

---

## Questions an interviewer will ask

| Question | Answer |
|---|---|
| Why a dictionary? | It turns the inner search from O(n) into O(1). A classic trade of space for time. |
| How do you avoid reusing an element? | The lookup happens before the insert, so the map only holds elements to the *left* of the current one. |
| Negatives? Zeros? Duplicates? | All fine. Subtraction handles signs; check-before-write handles duplicates. |
| Could it overflow? | `target - num` could overflow at the extremes of `Int`. The stated constraints (values ≤ 10⁹) rule it out — but naming it shows care. |
| What if you had to return *all* valid pairs? | No early return, and the map becomes `[Int: [Int]]` — a list of positions per value. |

**The three phrases that rebuild this from scratch:**

> **missing piece → number-to-position map → check before you write**

---

## Time and Space Complexity

### Time — O(n)

`n` is how many numbers are in the list.

We walk the list **once**. At each stop we do exactly three things:

| What we do | Cost |
|---|---|
| `target - num` — one subtraction | O(1) |
| `seen[diff]` — one dictionary lookup | O(1) |
| `seen[num] = index` — one dictionary insert | O(1) |

**O(1)** means "the cost doesn't grow with the size of the list". A dictionary lookup takes the
same time whether the notebook holds 5 numbers or 5 million — that's the entire reason we chose
a dictionary in Step 2.

So: n stops × constant work per stop = **O(n)**.

Compare with the brute force from Step 1, which checks every pair — that's **O(n²)**. For
10,000 numbers:

```
O(n²)  ≈ 50,000,000 checks
O(n)   =      10,000 checks
```

> **Small print:** dictionary operations are O(1) *on average*, not guaranteed. In a rare worst
> case where many numbers collide in the hash table, a lookup can slow down. Swift randomises
> its hashing on every run specifically to stop anyone engineering that. In an interview,
> "O(n) average" is the correct thing to say.

### Space — O(n)

"Space" means the **extra** memory we create, on top of the input we were handed.

Our extra memory is the `seen` dictionary. In the worst case — when the matching pair is right
at the end of the list — we end up writing down nearly every number before we find it. So the
notebook grows to about the size of the list: **O(n)**.

Best case is much smaller: for `[2, 7, 11, 15]` we find the answer on the second number, so
`seen` never holds more than one entry. But complexity is always quoted for the **worst** case.

The `diff`, `index` and `num` variables don't count — that's a fixed handful of values no matter
how long the list is, which is O(1).

### The trade we made

|  | Brute force | This solution |
|---|---|---|
| Time | O(n²) | **O(n)** |
| Space | O(1) | **O(n)** |

We **spent memory to buy speed.** That's the deal the hash map offers, and it's almost always
worth taking — memory is cheap, and a quadratic loop stops being usable long before memory
becomes a problem.

### Can it be beaten?

**No — not on time.** The answer might involve the very last number in the list, so any correct
solution must at minimum *read* every number once. That puts a floor of O(n) on the problem, and
we're sitting on it.

There is one alternative worth knowing: **sort the array, then walk two pointers inward** from
both ends. That gets space down to O(1), but costs O(n log n) time *and* sorting destroys the
original positions — which are exactly what this problem asks you to return. For unsorted input
where indices matter, the hash map is the right answer.
