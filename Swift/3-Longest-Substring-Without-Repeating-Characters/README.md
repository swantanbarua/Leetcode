# 3. Longest Substring Without Repeating Characters

**Difficulty:** Medium · **Status:** Accepted · [Problem link](https://leetcode.com/problems/longest-substring-without-repeating-characters/)

> Given a string `s`, find the length of the **longest substring** without duplicate characters.

**Examples**

```
s = "abcabcbb"   →   3     the answer is "abc" ("bca" and "cab" are also correct)
s = "bbbbb"      →   1     the answer is "b"
s = "pwwkew"     →   3     the answer is "wke"  —  "pwke" is a subsequence, NOT a substring
```

**Constraints**

- `0 <= s.length <= 10^5`
- `s` consists of English letters, digits, symbols and spaces.

---

## Step 1 — What are we actually being asked?

A **substring** is a run of characters that sit next to each other in the string. `"abc"` is a
substring of `"abcabcbb"`. `"pwke"` is *not* a substring of `"pwwkew"` — those letters are in
there, but not side by side. That's a **subsequence**, and it doesn't count.

We want the longest run of side-by-side characters where **no character appears twice**.
We only have to return the *length*, not the substring itself.

### The idea: a window that slides

Picture a window laid over the string. Inside the window there are never any repeats.

```
"abcabcbb"
 [abc]        ← a clean window of length 3
```

Slide the right edge forward one character at a time. Two things can happen:

- The new character is **not** inside the window → the window just gets bigger.
- The new character **is** inside the window → we have a repeat. Push the left edge forward
  until the old copy of that character is outside the window. Now it's clean again.

The biggest window we ever see is the answer.

### How do we know "is it already inside the window"?

We could scan the window every time, but that's slow. Instead keep a small **notebook**: for
each character, write down the **last index** where we saw it.

Then, when a new character arrives, one look in the notebook tells us where its previous copy
is. If that index is inside the window, it's a repeat, and we know exactly how far to move the
left edge — just past it.

So the plan, in one sentence:

> **Slide the right edge across the string. Before admitting each character, check the
> notebook — if its last copy is inside the window, jump the left edge past it. Record the
> character, measure the window, keep the biggest.**

The running example for every step below is `s = "abcabcbb"`.

---

## Step 2 — Turn the string into an array

```swift
var chars = Array(s)
```

A Swift `String` can't be indexed with a number. `s[3]` won't compile — Swift's string indices
are special objects, not integers. `Array(s)` turns the string into a plain array of
`Character`s, and an array *can* be indexed with `chars[3]`.

For `"abcabcbb"`:

```
index:  0   1   2   3   4   5   6   7
chars: "a" "b" "c" "a" "b" "c" "b" "b"
```

Now `chars[0]` is `"a"`, `chars[3]` is `"a"` again, `chars[7]` is `"b"`. Every line after
this uses `chars`, never `s`.

---

## Step 3 — The left edge of the window

```swift
var left = 0
```

`left` is the index where the current window **starts**. The window is always
`chars[left ... right]`, where `right` will be the loop variable.

At the start the window begins at index 0:

```
index:  0   1   2   3   4   5   6   7
chars: "a" "b" "c" "a" "b" "c" "b" "b"
        ^
     left = 0
```

`left` only ever moves to the **right**, never back. When we hit a repeat, it jumps past the
old copy of that character.

---

## Step 4 — The answer so far

```swift
var best = 0
```

`best` remembers the longest window seen so far. It starts at 0 — which happens to be the
correct answer for an empty string, so `s = ""` is handled for free.

As the loop runs on `"abcabcbb"` it will grow like this:

```
right = 0   window "a"     length 1   best = 1
right = 1   window "ab"    length 2   best = 2
right = 2   window "abc"   length 3   best = 3
right = 3   window "bca"   length 3   best = 3   (not bigger, stays)
```

---

## Step 5 — The notebook

```swift
var lastSeen: [Character : Int] = [:]
```

A dictionary: the **key** is a character, the **value** is the last index we saw it at.
It starts empty.

```
lastSeen = [:]        (nothing written yet)
```

After we pass index 2 it will be:

```
lastSeen = ["a": 0, "b": 1, "c": 2]
```

When we reach index 3 (the second `"a"`), `lastSeen["a"]` gives `0` instantly — no need to
scan backwards through the window.

---

## Step 6 — The loop

```swift
for right in 0..<chars.count {

}
```

`right` is the **right edge** of the window. It walks from index 0 to the last index, one step
at a time, never skipping and never going back.

Everything inside the loop answers one question: *now that the window ends at `right`, where
should `left` be, and how long is the window?*

For `"abcabcbb"`, `chars.count` is 8, so the loop runs 8 times:

```
right = 0 → looking at "a"
right = 1 → looking at "b"
right = 2 → looking at "c"
right = 3 → looking at "a"   ← the first repeat
right = 4 → looking at "b"
right = 5 → looking at "c"
right = 6 → looking at "b"
right = 7 → looking at "b"
```

---

## Step 7 — The key check: is this character already in the window?

```swift
if let prev = lastSeen[chars[right]], prev >= left {

}
```

Two things must **both** be true for a repeat to matter:

| Condition | Plain English |
|---|---|
| `if let prev = lastSeen[chars[right]]` | We've seen this character before. Its last index is unwrapped into `prev`. |
| `prev >= left` | That old copy is **inside** the current window — not somewhere behind it. |

The comma between them means *and*. If the character was never seen, `lastSeen[...]` is
`nil`, `if let` fails, and the whole `if` is skipped.

On `"abcabcbb"`:

```
right = 0, "a"   lastSeen["a"] = nil                → not a repeat
right = 3, "a"   prev = 0,  left = 0,  0 >= 0  ✓    → repeat! the old "a" is in the window
right = 4, "b"   prev = 1,  left = 1,  1 >= 1  ✓    → repeat!
```

### Why the second condition matters

Take `"abba"`:

```
index:  0   1   2   3
chars: "a" "b" "b" "a"
```

At `right = 2` (the second `"b"`) we'll move `left` to 2. Then at `right = 3`, the character
is `"a"` and `prev = 0`.

- **Without** `prev >= left`: we'd think "a" is a repeat and set `left = 1` — moving it
  **backwards**. The window would become `"bba"`, which has a repeat. Wrong.
- **With** it: `0 >= 2` is false, so that stale `"a"` is ignored. The window is `"ba"`. Correct.

A character that lives *before* the window can't cause a repeat *inside* it.

---

## Step 8 — Shrink the window past the old copy

```swift
left = prev + 1
```

If the old copy sits at index `prev`, the window must start **just after** it. That throws out
the old copy and everything before it in a single jump, and the window is clean again.

At `right = 3` on `"abcabcbb"`, `prev = 0`:

```
before:  index  0   1   2   3
                "a" "b" "c" "a"
                 ^           ^
              left=0      right=3      window "abca"  —  two a's

after:   left = 0 + 1 = 1
                "a" "b" "c" "a"
                     ^       ^
                  left=1  right=3      window "bca"   —  clean
```

Later, at `right = 6`, `prev = 4`, and `left` is 3:

```
before:  left = 3,  window chars[3...6] = "abcb"   —  two b's
after:   left = 5,  window chars[5...6] = "cb"     —  clean
```

`left` jumped from 3 straight to 5. It never crawls one step at a time — it always lands right
after the repeat.

---

## Step 9 — Write the character into the notebook

```swift
lastSeen[chars[right]] = right
```

Whether or not it was a repeat, record *"I last saw this character at index `right`."* If the
character is already in the notebook, this **overwrites** the old index with the newer one —
which is what we want, because only the most recent copy can ever be inside the window.

### This line must come *after* the `if`

If we wrote it first, then at `right = 3` we'd set `lastSeen["a"] = 3`, read `prev = 3`, and
jump `left` to 4. The window would wrongly collapse to nothing. The check has to see the
*old* index, so the write goes after it.

Watching the notebook fill on `"abcabcbb"`:

```
right = 0   lastSeen = ["a": 0]
right = 1   lastSeen = ["a": 0, "b": 1]
right = 2   lastSeen = ["a": 0, "b": 1, "c": 2]
right = 3   lastSeen = ["a": 3, "b": 1, "c": 2]   ← "a" overwritten 0 → 3
right = 4   lastSeen = ["a": 3, "b": 4, "c": 2]   ← "b" overwritten 1 → 4
right = 5   lastSeen = ["a": 3, "b": 4, "c": 5]
right = 6   lastSeen = ["a": 3, "b": 6, "c": 5]
right = 7   lastSeen = ["a": 3, "b": 7, "c": 5]
```

---

## Step 10 — Measure the window and keep the biggest

```swift
best = max(best, right - left + 1)
```

The window is `chars[left ... right]`, so its length is `right - left + 1`. The `+ 1` is because
**both ends are included**: indices 1, 2, 3 is `3 - 1 + 1 = 3` characters, not 2.

`max` keeps `best` unless this window is bigger.

The full picture on `"abcabcbb"`:

| `right` | char | `left` | window | length | `best` |
|---|---|---|---|---|---|
| 0 | `a` | 0 | `a` | 1 | 1 |
| 1 | `b` | 0 | `ab` | 2 | 2 |
| 2 | `c` | 0 | `abc` | 3 | **3** |
| 3 | `a` | 1 | `bca` | 3 | 3 |
| 4 | `b` | 2 | `cab` | 3 | 3 |
| 5 | `c` | 3 | `abc` | 3 | 3 |
| 6 | `b` | 5 | `cb` | 2 | 3 |
| 7 | `b` | 7 | `b` | 1 | 3 |

`best` reaches 3 at `right = 2` and nothing later beats it.

---

## Step 11 — Return the answer

```swift
return best
```

Once the loop has looked at every character, `best` holds the length of the longest clean
window we ever saw. For `"abcabcbb"` that's **3**.

---

## Step 12 — Watch it run on the other examples

### `"bbbbb"` → 1

| `right` | char | `prev` | `left` | window | length | `best` |
|---|---|---|---|---|---|---|
| 0 | `b` | nil | 0 | `b` | 1 | 1 |
| 1 | `b` | 0 | 1 | `b` | 1 | 1 |
| 2 | `b` | 1 | 2 | `b` | 1 | 1 |
| 3 | `b` | 2 | 3 | `b` | 1 | 1 |
| 4 | `b` | 3 | 4 | `b` | 1 | 1 |

Every character is a repeat of the one before it, so `left` chases `right` and the window is
never wider than 1. ✓

### `"pwwkew"` → 3

| `right` | char | `prev` | `left` | window | length | `best` |
|---|---|---|---|---|---|---|
| 0 | `p` | nil | 0 | `p` | 1 | 1 |
| 1 | `w` | nil | 0 | `pw` | 2 | 2 |
| 2 | `w` | 1 | 2 | `w` | 1 | 2 |
| 3 | `k` | nil | 2 | `wk` | 2 | 2 |
| 4 | `e` | nil | 2 | `wke` | 3 | **3** |
| 5 | `w` | 2 | 3 | `kew` | 3 | 3 |

At `right = 5`, `prev = 2` and `left = 2`, so `2 >= 2` is true — the `"w"` at index 2 is still in
the window, and `left` jumps to 3. The window stays a real substring the whole time; `"pwke"`
never appears because those letters are never side by side. ✓

### `"abba"` → 2 — the stale-index case

| `right` | char | `prev` | `prev >= left`? | `left` | window | `best` |
|---|---|---|---|---|---|---|
| 0 | `a` | nil | — | 0 | `a` | 1 |
| 1 | `b` | nil | — | 0 | `ab` | 2 |
| 2 | `b` | 1 | `1 >= 0` ✓ | 2 | `b` | 2 |
| 3 | `a` | 0 | `0 >= 2` ✗ | 2 | `ba` | 2 |

Row 3 is the whole reason `prev >= left` is in the `if`. Without it, `left` would go backwards
to 1 and the "window" `"bba"` would have a repeat in it. ✓

---

## The finished solution

```swift
class Solution {
    func lengthOfLongestSubstring(_ s: String) -> Int {
        
        var chars = Array(s)
        var left = 0
        var best = 0
        var lastSeen: [Character : Int] = [:]
        
        for right in 0..<chars.count {
            if let prev = lastSeen[chars[right]], prev >= left {
                left = prev + 1
            }
            
            lastSeen[chars[right]] = right
            best = max(best, right - left + 1)
        }
        
        return best
    }
}
```

---

## Questions an interviewer will ask

| Question | Answer |
|---|---|
| What's the brute force? | Try every pair `(i, j)`, check the substring for repeats. O(n³), or O(n²) with a set. Far too slow for 10⁵. |
| Why a sliding window? | Once a window has a repeat, every wider window starting at the same `left` also has it. So `left` only needs to move forward — each index is entered and left at most once. |
| Why store the *index* and not just a set of characters? | With a set you'd have to move `left` one step at a time, removing characters as you go. Storing the index lets `left` jump straight past the repeat. |
| Why `prev >= left`? | A character's last index might be *before* the window (`"abba"`). Acting on it would move `left` backwards. |
| Why write to the notebook *after* the check? | Writing first would make the current character look like its own repeat and collapse the window. |
| Why `Array(s)`? | Swift strings can't be indexed by `Int`. The array can. |
| Could you use an array instead of a dictionary? | Yes — a `[Int]` of size 128 indexed by ASCII value. Same idea, slightly faster, but only if the alphabet is known to be ASCII. |
| What does it return for `""`? | 0 — the loop never runs and `best` starts at 0. |

**The three phrases that rebuild this from scratch:**

> **slide `right` → if the last copy is inside the window, jump `left` past it → record, measure, keep the max**

---

## Time and Space Complexity

### Time — O(n)

`n` is the length of the string.

`right` visits every index exactly once — that's `n` steps. Inside each step:

| What we do | Cost |
|---|---|
| `lastSeen[chars[right]]` lookup | O(1) average |
| `prev >= left` comparison | O(1) |
| `left = prev + 1` | O(1) |
| `lastSeen[chars[right]] = right` | O(1) average |
| `max(best, right - left + 1)` | O(1) |

`left` only ever moves forward, so across the whole run it moves at most `n` times total —
and here it moves in a single assignment, not a loop. So the whole thing is **O(n)**.

`Array(s)` at the top is one O(n) pass too. It doesn't change the total.

### Space — O(k)

`k` is the number of **distinct** characters in `s`. The notebook holds at most one entry per
distinct character — a character seen twice just overwrites its own entry.

The constraints say `s` is English letters, digits, symbols and spaces — a small, fixed
alphabet (at most 128 ASCII characters). So `k` is bounded by a constant, and most people
call this **O(1)**. Say both in an interview: *"O(min(n, k)), which is O(1) for a fixed alphabet."*

`Array(s)` also takes O(n) space. That's a Swift indexing convenience, not part of the
algorithm — in a language with integer string indices it wouldn't exist.

### Can it be beaten?

**No.** Any correct solution must look at every character at least once — the last character
might extend the best window — so O(n) is a floor, and we're on it.
