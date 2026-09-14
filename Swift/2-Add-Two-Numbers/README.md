# 2. Add Two Numbers

**Difficulty:** Medium · **Status:** Accepted · [Problem link](https://leetcode.com/problems/add-two-numbers/)

> You are given two **non-empty** linked lists representing two non-negative integers. The
> digits are stored in **reverse order**, and each of their nodes contains a single digit. Add
> the two numbers and return the sum as a linked list.
>
> You may assume the two numbers do not contain any leading zero, except the number 0 itself.

**Examples**

```
l1 = [2,4,3],           l2 = [5,6,4]    →   [7,0,8]              because 342 + 465 = 807
l1 = [0],               l2 = [0]        →   [0]
l1 = [9,9,9,9,9,9,9],   l2 = [9,9,9,9]  →   [8,9,9,9,0,0,0,1]    because 9999999 + 9999 = 10009999
```

**Constraints**

- The number of nodes in each linked list is in the range `[1, 100]`.
- `0 <= Node.val <= 9`
- It is guaranteed that the list represents a number that does not have leading zeros.

---

## Step 1 — What are we actually being asked?

You get two numbers. But they aren't handed to you as normal numbers like `342`. Each one is
chopped into single digits, and each digit sits in its own box, chained together — a
**linked list**.

```
l1:  2 → 4 → 3
l2:  5 → 6 → 4
```

### The twist: the digits are stored backwards

Read `2 → 4 → 3` from right to left and you get **342**. Read `5 → 6 → 4` right to left and
you get **465**.

So the **first box holds the ones digit**, the second box holds the tens, the third the hundreds.

```
box:     1st   2nd   3rd
l1:       2     4     3
means:   ones  tens  hundreds   →  342
```

### What we must return

Add the two numbers — `342 + 465 = 807` — and hand the answer back **in the same backwards
format**:

```
807  →  7 → 0 → 8
```

### Why "backwards" is good news

Think about how you add on paper:

```
      1          ← the carry
    3 4 2
  + 4 6 5
  -------
    8 0 7
```

You **always** start from the rightmost digit — the ones column — because a carry flows
*leftwards*, into the next column.

Now look at the lists. The **first** box of `l1` is `2` — the ones digit. The **first** box
of `l2` is `5` — also the ones digit. The list hands you the digits in **exactly the order
you'd add them by hand**. Walk both lists from the front, adding as you go. No reversing needed.

### The three moves at every column

| Move | Example (tens column of 342 + 465) |
|---|---|
| 1. Add the two digits, plus any carry from before | `4 + 6 + 0 = 10` |
| 2. Write down the **last digit** of that | write **0** |
| 3. Remember the **carry** for the next column | carry **1** |

All three columns of Example 1:

| column | digit from l1 | digit from l2 | carry in | sum | write | carry out |
|---|---|---|---|---|---|---|
| ones | 2 | 5 | 0 | 7 | **7** | 0 |
| tens | 4 | 6 | 0 | 10 | **0** | 1 |
| hundreds | 3 | 4 | 1 | 8 | **8** | 0 |

Written digits in order: `7, 0, 8`. ✓

### Two things to watch for

**Different lengths.** `[9,9,9,9,9,9,9]` has 7 digits, `[9,9,9,9]` has 4. On paper you'd
just treat the missing digits of the shorter number as **0**:

```
    9 9 9 9 9 9 9
  + 0 0 0 9 9 9 9
```

**A leftover carry.** `9999999 + 9999 = 10009999` — the answer has **8** digits, one more than
either input. After both lists run out there's still a `1` to write down.

### Why we can't just convert to numbers

Each list can be 100 boxes long. A 100-digit number is far too big for an `Int` (which tops out
around 19 digits). So "turn both into numbers, add, turn back" would overflow. We *must* add
digit by digit — which is what paper addition does anyway.

So the plan, in one sentence:

> **Walk both lists from the front. At each stop: add the two digits and the carry, write the
> last digit, keep the carry. Treat a missing digit as 0. Don't forget a leftover carry at the
> end.**

---

## Step 2 — What is a `ListNode`?

LeetCode gives you this at the top of the file:

```swift
public class ListNode {
    public var val: Int
    public var next: ListNode?
}
```

A node is a tiny box holding **two things**:

| Part | Meaning |
|---|---|
| `val` | The digit inside this box |
| `next` | A pointer to the **next** box — or `nil` if this is the last one |

So `[2,4,3]` is really three boxes chained together:

```
┌───┐    ┌───┐    ┌───┐
│ 2 │ →  │ 4 │ →  │ 3 │ →  nil
└───┘    └───┘    └───┘
```

`l1` isn't the whole list — it's just the **first box**. To see the rest, you follow the arrows:

```swift
l1              // the box holding 2
l1?.next        // the box holding 4
l1?.next?.next  // the box holding 3
```

The `?` is there because `next` is `ListNode?` — an **Optional**, a box that might be empty.
It might point to a node, or it might be `nil`.

With an array you can jump anywhere: `nums[2]`. With a linked list you **can't**. You start at
the front and walk forward, one arrow at a time. That's fine — Step 1 showed we *want* to go
front-to-back anyway.

---

## Step 3 — The carry

```swift
var carry = 0
```

`4 + 6 = 10` → write **0**, carry **1** to the next column. That `1` has to be remembered until
we reach the next column. This variable is where we remember it.

| Part | Meaning |
|---|---|
| `var` | It changes — 0 in some columns, 1 in others |
| `carry` | The digit we carry over |
| `= 0` | Before the first column, there is nothing to carry yet |

---

## Step 4 — A finger on each list

```swift
var pointer1 = l1
var pointer2 = l2
```

We're going to walk along each list one box at a time. To walk, you need something that
**moves** — a finger you slide from box to box.

`l1` itself can't be that finger. In Swift a function parameter is a constant. Write
`l1 = l1?.next` and the compiler refuses. So we make a copy we *are* allowed to move.

| Part | Meaning |
|---|---|
| `var` | The finger slides forward every column |
| `pointer1` | Our finger on list 1 |
| `= l1` | Start on the **first box** of `l1` — the ones digit |

Same for `pointer2`. Both fingers now sit on the ones digits:

```
l1:   2 → 4 → 3          l2:   5 → 6 → 4
      ↑                        ↑
   pointer1                 pointer2
```

`pointer1` is on **2**, `pointer2` is on **5**. That's the first column: `2 + 5`.

---

## Step 5 — A place to hang the answer

```swift
let dummyNode = ListNode(0)
```

We'll be creating answer boxes one by one — `7`, then `0`, then `8` — and chaining them
together. But chaining has an awkward first step: the very first box has nothing before it to
attach to.

The trick: make a **fake first box** before we start. It holds a throwaway `0` that is *not*
part of the answer. Every real box gets hung off it.

```
dummyNode:  0 →  (nothing yet)
```

Later it will look like:

```
dummyNode:  0 → 7 → 0 → 8
            ↑   ↑
         fake   real answer starts here
```

At the end we return whatever comes *after* the dummy, and the fake `0` is never seen.

| Part | Meaning |
|---|---|
| `let` | The dummy never changes — it always stays the fake first box |
| `ListNode(0)` | Make a new box holding `0`, with `next` set to `nil` |

---

## Step 6 — A finger on the answer

```swift
var dummyPointer = dummyNode
```

We need a third finger — on the **answer** list — that always points at the **last box we
built**. Whenever we make a new box, we hang it off this finger, then slide the finger onto
the new box.

Right now the only answer box is the dummy, so the finger starts there:

```
dummyNode:  0
            ↑
       dummyPointer
```

### ⚠️ This is the most important idea in the whole problem

`ListNode` is a **class**. When you write `var dummyPointer = dummyNode`, Swift does **not**
make a copy of the box. It gives the *same* box a second name. Two labels, one object.

Think of a house. `dummyNode` and `dummyPointer` are two people who both have the address of
the same house. If `dummyPointer` walks in and builds an extension on the back, `dummyNode`
sees the extension too — it's the same house.

So later, when we do `dummyPointer.next = ListNode(7)`, we're attaching the `7` box to **the
box that `dummyNode` also names**. Then `dummyPointer` walks forward — but `dummyNode` stays
at the front. That's why `dummyNode` is `let` and `dummyPointer` is `var`.

> This is different from `Int`, `String`, arrays and dictionaries, which are **value types** —
> those *do* get copied on assignment. Two Sum's `seen` dictionary was a value type. `ListNode`
> is a class, so it isn't. That difference is exactly what makes the dummy-head trick work.

---

## Step 7 — The loop

```swift
while pointer1 != nil || pointer2 != nil || carry != 0 {

}
```

One trip through this loop = one **column** of the addition. So: *when do we stop?*

On paper you stop when there are **no digits left in either number** and **nothing left to
carry**. Flip that around, and you *keep going* while **any** of these three is true:

| Condition | Plain English |
|---|---|
| `pointer1 != nil` | List 1 still has boxes left |
| `pointer2 != nil` | List 2 still has boxes left |
| `carry != 0` | There's a leftover carry to write down |

`||` means **or** — if even one is true, do another column.

- The first two handle **different lengths**. With `[9,9,9,9,9,9,9]` and `[9,9,9,9]`,
  `pointer2` runs out after 4 boxes, but `pointer1` still has 3 more — so we keep looping.
- The third handles the **final carry**. `9999999 + 9999 = 10009999`. After both lists run
  out, `carry` is still `1`. This condition forces one more trip to write that `1` as an
  extra box — that's why the output has 8 digits.

---

## Step 8 — Read the two digits

```swift
let value1 = pointer1?.val ?? 0
let value2 = pointer2?.val ?? 0
```

We want the digit under each finger. But a finger might be `nil` — its list may have already
run out. This one line handles both cases:

| Part | Meaning |
|---|---|
| `pointer1?.val` | "If `pointer1` is on a box, give me its digit. If it's `nil`, give me nothing." |
| `?? 0` | "…and if you got nothing, use **0** instead." |

`??` is the **nil-coalescing** operator. Plain reading: *"this, or else that."*

```
pointer1 on the box holding 4   →   value1 = 4
pointer1 is nil (list ran out)  →   value1 = 0
```

That `0` is exactly the paper trick from Step 1 — when the shorter number runs out of digits,
you pretend it has zeros:

```
    9 9 9 9 9 9 9
  + 0 0 0 9 9 9 9      ← the 0s are what ?? 0 gives us
```

`let`, not `var` — each is read once per column and never changed.

---

## Step 9 — Add the column

```swift
let currentSum = value1 + value2 + carry
```

Paper addition itself: **both digits, plus whatever was carried in from the previous column.**

| column | `value1` | `value2` | `carry` | `currentSum` |
|---|---|---|---|---|
| ones | 2 | 5 | 0 | **7** |
| tens | 4 | 6 | 0 | **10** |
| hundreds | 3 | 4 | 1 | **8** |

`currentSum` can be **two digits** — 10 in the tens column. That's fine; the next two lines
split it into "the digit we write" and "the digit we carry".

How big can it get? Each digit is at most 9, the carry is at most 1. So `9 + 9 + 1 = 19`.
Never more. That's why a carry is always `0` or `1` — never `2`.

---

## Step 10 — Split the sum: carry and digit

```swift
carry = currentSum / 10
dummyPointer.next = ListNode(currentSum % 10)
```

`currentSum` is between 0 and 19. We need to split it into two pieces:

```
currentSum = 10   →   write 0,  carry 1
currentSum = 7    →   write 7,  carry 0
currentSum = 19   →   write 9,  carry 1
```

### `/ 10` — the carry

The carry is the **tens digit**. To get the tens digit, divide by 10:

| `currentSum` | `currentSum / 10` |
|---|---|
| 7 | 0 |
| 10 | 1 |
| 19 | 1 |

This works because `/` on two `Int`s in Swift is **whole-number division** — it throws away
the remainder. `19 / 10` is `1`, not `1.9`.

We're **overwriting** `carry`, not making a new variable. Whatever was carried *into* this
column has already been used (in the `currentSum` line). Now `carry` holds what we carry *out*
to the next column.

### `% 10` — the digit we write

`%` gives the **remainder** after dividing by 10. That's the ones digit:

| `currentSum` | `currentSum % 10` |
|---|---|
| 7 | 7 |
| 10 | 0 |
| 19 | 9 |

So `/ 10` gave us the tens digit (carry) and `% 10` gives us the ones digit (write). Together
they split `currentSum` cleanly.

### `dummyPointer.next = ListNode(...)` — hang it on the answer

`ListNode(currentSum % 10)` makes a brand-new box holding that digit. `dummyPointer.next = `
attaches it **after** the box `dummyPointer` is standing on.

First column of Example 1, `currentSum = 7`:

```
before:   dummyNode: 0
                     ↑
                dummyPointer

after:    dummyNode: 0 → 7
                     ↑
                dummyPointer      (still on the dummy — hasn't moved yet)
```

---

## Step 11 — Slide all three fingers forward

```swift
dummyPointer = dummyPointer.next!
pointer1 = pointer1?.next
pointer2 = pointer2?.next
```

### The answer finger

We just hung a new box off `dummyPointer`. Now move `dummyPointer` **onto** that new box, so
the *next* column's box gets hung after it — not after the dummy again.

```
before:   dummyNode: 0 → 7
                     ↑
                dummyPointer

after:    dummyNode: 0 → 7
                         ↑
                    dummyPointer
```

Without this line, every column would overwrite `dummyNode.next`, and the answer would only
ever be one box long.

**About the `!`.** In Two Sum the rule was: never use `!` on a dictionary lookup, because the
box might be empty. So why is it fine here?

`dummyPointer.next` is a `ListNode?` — an Optional — because in general a box's `next` *might*
be `nil`. But look at the line directly above it: we **just set** `dummyPointer.next` to a
brand-new node. There is no possible way it's `nil` right now. When you're certain, `!` is safe.

> The rule isn't "never use `!`". It's **"only use `!` when the line above proves it can't be
> empty."**

### The two input fingers

```
before:   l1:  2 → 4 → 3
               ↑
           pointer1

after:    l1:  2 → 4 → 3
                   ↑
               pointer1
```

Here we use `?`, not `!`, because we have **no guarantee** `pointer1` is on a box — its list
may have already run out.

```
pointer1 on the last box (3)  →  pointer1?.next is nil        →  pointer1 becomes nil  (list finished)
pointer1 is already nil       →  pointer1?.next is also nil   →  pointer1 stays nil    (no crash)
```

So once a list runs out, its finger just sits at `nil` for the remaining columns, and Step 8's
`?? 0` keeps feeding zeros. Everything fits together.

After the first column of Example 1:

```
l1:   2 → 4 → 3       l2:   5 → 6 → 4       dummyNode: 0 → 7
          ↑                     ↑                          ↑
      pointer1              pointer2                  dummyPointer

carry = 0
```

The loop goes back to the top and checks its three conditions.

---

## Step 12 — Return the answer

```swift
return dummyNode.next
```

When the loop ends, the answer chain looks like this:

```
dummyNode: 0 → 7 → 0 → 8
           ↑   ↑
        fake   real answer
```

The fake `0` was only there to give us something to hang the first box on. The real answer
starts at the box **after** it — `dummyNode.next`. So that's what we return.

- Not `dummyNode` — that would return `[0,7,0,8]`.
- Not `dummyPointer` — that's the *last* box, and you'd get just `[8]`.

`dummyNode` is the only thing still pointing at the **front** of the chain. That's why it was a
`let` and never moved.

### Why `dummyNode.next` and not `dummyNode?.next`

`ListNode(0)` creates a node and hands it straight back — no "maybe". So `dummyNode` is a plain
**`ListNode`**, not `ListNode?`. The `?.` operator only exists for Optionals; Swift won't even
let you write `dummyNode?.next`.

| Variable | Type | Why | How you reach `next` |
|---|---|---|---|
| `dummyNode` | `ListNode` | We created it ourselves — it definitely exists | `dummyNode.next` |
| `dummyPointer` | `ListNode` | Started as `dummyNode`, and each move used `!` to keep it non-optional | `dummyPointer.next` |
| `pointer1`, `pointer2` | `ListNode?` | Copied from parameters that are `ListNode?` — they may run out and become `nil` | `pointer1?.next` |

Rule of thumb: **`?.` when the thing on the left could be `nil`. Plain `.` when it can't.**

`dummyNode` isn't optional, but `dummyNode.next` **is** — a node's `next` can always be `nil`.
That's exactly what the function promises to return (`-> ListNode?`), so it matches the
signature with no unwrapping needed.

---

## Step 13 — Watch it run, line by line

### Example 1: `[2,4,3] + [5,6,4]` → `[7,0,8]`

**Before the loop:** `carry = 0`, `pointer1` on 2, `pointer2` on 5, `dummyNode: 0`,
`dummyPointer` on the dummy.

**Column 1 (ones)** — loop check: `pointer1 != nil` ✓, so enter.

```swift
let value1 = pointer1?.val ?? 0     // 2
let value2 = pointer2?.val ?? 0     // 5
let currentSum = value1 + value2 + carry   // 2 + 5 + 0 = 7
carry = currentSum / 10             // 7 / 10 = 0
dummyPointer.next = ListNode(currentSum % 10)   // 7 % 10 = 7  →  hang a [7]
dummyPointer = dummyPointer.next!   // move onto [7]
pointer1 = pointer1?.next           // now on 4
pointer2 = pointer2?.next           // now on 6
```

```
dummyNode: 0 → 7        carry = 0
```

**Column 2 (tens)** — `pointer1` on 4, `pointer2` on 6.

```swift
value1 = 4, value2 = 6
currentSum = 4 + 6 + 0 = 10
carry = 10 / 10 = 1                 // carry the 1!
dummyPointer.next = ListNode(10 % 10 = 0)   // hang a [0]
dummyPointer = dummyPointer.next!   // move onto [0]
pointer1 → 3,  pointer2 → 4
```

```
dummyNode: 0 → 7 → 0    carry = 1
```

**Column 3 (hundreds)** — `pointer1` on 3, `pointer2` on 4.

```swift
value1 = 3, value2 = 4
currentSum = 3 + 4 + 1 = 8          // the carried 1 is used here
carry = 8 / 10 = 0
dummyPointer.next = ListNode(8 % 10 = 8)    // hang an [8]
dummyPointer = dummyPointer.next!
pointer1 → nil,  pointer2 → nil     // both lists finished
```

```
dummyNode: 0 → 7 → 0 → 8    carry = 0
```

**Loop check:** `pointer1 != nil`? no. `pointer2 != nil`? no. `carry != 0`? no. **Stop.**

```swift
return dummyNode.next               // → 7 → 0 → 8
```

Answer `[7,0,8]`, which is 807 backwards. `342 + 465 = 807` ✓

### The same thing as one table

| column | `value1` | `value2` | carry in | `currentSum` | write | carry out | answer so far |
|---|---|---|---|---|---|---|---|
| 1 | 2 | 5 | 0 | 7 | 7 | 0 | `7` |
| 2 | 4 | 6 | 0 | 10 | 0 | 1 | `7 → 0` |
| 3 | 3 | 4 | 1 | 8 | 8 | 0 | `7 → 0 → 8` |

### Example 3: `[9,9,9,9,9,9,9] + [9,9,9,9]` → `[8,9,9,9,0,0,0,1]`

This one exercises both special cases — different lengths *and* a leftover carry.

| column | `pointer1` | `pointer2` | `value1` | `value2` | carry in | `currentSum` | write | carry out |
|---|---|---|---|---|---|---|---|---|
| 1 | 9 | 9 | 9 | 9 | 0 | 18 | 8 | 1 |
| 2 | 9 | 9 | 9 | 9 | 1 | 19 | 9 | 1 |
| 3 | 9 | 9 | 9 | 9 | 1 | 19 | 9 | 1 |
| 4 | 9 | 9 | 9 | 9 | 1 | 19 | 9 | 1 |
| 5 | 9 | **nil** | 9 | **0** | 1 | 10 | 0 | 1 |
| 6 | 9 | nil | 9 | 0 | 1 | 10 | 0 | 1 |
| 7 | 9 | nil | 9 | 0 | 1 | 10 | 0 | 1 |
| 8 | **nil** | nil | **0** | 0 | 1 | 1 | 1 | 0 |

Three things to notice:

- **Column 5** — `pointer2` ran out. `?? 0` quietly supplies a `0` and nothing breaks.
- **Column 8** — *both* lists are `nil`, but `carry` is still `1`. The `|| carry != 0` in the
  loop condition is what lets this column happen. Without it the answer would be
  `[8,9,9,9,0,0,0]` — missing the final `1`.
- **After column 8** — `carry` is `0`, both pointers are `nil`. All three conditions false.
  Stop.

Result: `[8,9,9,9,0,0,0,1]` — that's `10009999` backwards. `9999999 + 9999 = 10009999` ✓

---

## The finished solution

```swift
class Solution {
    func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
        
        var carry = 0
        var pointer1 = l1
        var pointer2 = l2
        let dummyNode = ListNode(0)
        var dummyPointer = dummyNode

        while pointer1 != nil || pointer2 != nil || carry != 0 {

            let value1 = pointer1?.val ?? 0
            let value2 = pointer2?.val ?? 0
            let currentSum = value1 + value2 + carry
            carry = currentSum / 10
            dummyPointer.next = ListNode(currentSum % 10)
            dummyPointer = dummyPointer.next!
            pointer1 = pointer1?.next
            pointer2 = pointer2?.next
        }

        return dummyNode.next
    }
}
```

---

## Questions an interviewer will ask

| Question | Answer |
|---|---|
| Why not convert both lists to integers, add, and convert back? | Up to 100 digits — far beyond what an `Int` holds. Digit-by-digit addition has no size limit. |
| Why a dummy head? | It gives the first real node something to attach to, so there's no special case for "is this the first node?". `dummyNode` stays at the front; `dummyPointer` walks. |
| Why does the loop condition include `carry != 0`? | For a final carry-out with no digits left — `999 + 1 = 1000` needs one more node than either input. |
| How do you handle lists of different lengths? | `?? 0`: a `nil` pointer reads as digit 0, the same as padding the shorter number with leading zeros on paper. |
| What if the digits were stored in *forward* order? | Reverse both lists first (or use a stack), then apply this exact algorithm. That's LeetCode 445. |
| Could you do it recursively? | Yes — each call adds one column and recurses on the `.next` of both. It's the same logic, but the iterative version uses O(1) extra space rather than O(n) stack. |

**The three phrases that rebuild this from scratch:**

> **paper addition from the front → `?? 0` for a missing digit → loop while any list or carry remains**

---

## Time and Space Complexity

### Time — O(max(m, n))

`m` and `n` are the lengths of the two lists.

Each trip through the loop does a fixed amount of work — two reads, one add, one divide, one
remainder, one node creation, three pointer moves. Nothing inside the loop grows with the input.

| What we do | Cost |
|---|---|
| `pointer1?.val ?? 0`, `pointer2?.val ?? 0` | O(1) |
| `value1 + value2 + carry`, `/ 10`, `% 10` | O(1) |
| `ListNode(...)` and hanging it on | O(1) |
| Sliding the three fingers | O(1) |

How many trips? The loop runs until the **longer** list runs out — that's `max(m, n)` trips —
plus at most **one** extra trip for a leftover carry. So `max(m, n) + 1`, and the `+ 1`
vanishes in Big-O: **O(max(m, n))**.

Compare this to the brute-force idea of converting to integers: even if `Int` could hold the
numbers, you'd still walk every node to build them, so it wouldn't be faster — it would just be
wrong for long inputs.

### Space — O(max(m, n))

The answer list has one node per column, so `max(m, n)` nodes, possibly plus one. That's the
memory this function creates.

Whether that counts is a matter of convention. Many interviewers treat the **output** as
required — you *have* to return a list, and it *has* to be that long — and only count what's
used *beyond* the output. By that measure the extra space is **O(1)**: `carry`, `pointer1`,
`pointer2`, `dummyNode`, `dummyPointer` — a fixed handful of variables, no matter how long the
lists are.

In an interview, say both: *"O(max(m, n)) for the result list, O(1) auxiliary."*

### Can it be beaten?

**No.** The answer may depend on the very last digit of the longer list (a carry can ripple all
the way through — `999 + 1`), so any correct solution must read every node once. That's a floor
of O(max(m, n)), and we're sitting on it.

The one memory trick worth knowing: reuse the nodes of one input list for the answer instead
of creating new ones. That drops the *allocation* to O(1) at the cost of mutating an input —
usually considered bad form unless the interviewer asks for it.
