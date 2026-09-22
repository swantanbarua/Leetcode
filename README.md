# LeetCode

My LeetCode solutions, each with a step-by-step explanation and complexity analysis.

The goal here is **not** to collect accepted submissions. It's to be able to re-derive every
solution from scratch months later. So each problem gets the reasoning that led to the code —
in plain language — not just the code.

Solutions are organised by language. Swift is where I'm starting; the same problems will be
solved in other languages as I go.

## How this is organised

```
Leetcode/
└── <Language>/
    └── <n>-<Problem-Name>/
        ├── README.md
        └── <n>-<Problem-Name>.<ext>
```

Every problem folder contains:

- **`README.md`** — the problem, then the solution explained step by step in simple terms,
  ending with the time and space complexity.
- **the solution file** — the accepted code, with the problem statement and approach
  summarised in comments.

## Languages

| Language | Folder | Solved |
|---|---|---|
| Swift | [`Swift/`](Swift/) | 5 |

## Solved

| # | Problem | Difficulty | Topic | Solutions |
|---|---------|-----------|-------|-----------|
| 1 | [Two Sum](https://leetcode.com/problems/two-sum/) | Easy | Hash Map | [Swift](Swift/1-Two-Sum/) |
| 2 | [Add Two Numbers](https://leetcode.com/problems/add-two-numbers/) | Medium | Linked List | [Swift](Swift/2-Add-Two-Numbers/) |
| 3 | [Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) | Medium | Sliding Window | [Swift](Swift/3-Longest-Substring-Without-Repeating-Characters/) |
| 4 | [Median of Two Sorted Arrays](https://leetcode.com/problems/median-of-two-sorted-arrays/) | Hard | Binary Search | [Swift](Swift/4-Median-of-Two-Sorted-Arrays/) |
| 5 | [Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/) | Medium | Two Pointers | [Swift](Swift/5-Longest-Palindromic-Substring/) |

## Running a solution locally

Each solution file is standalone — no project setup needed.

```bash
# Swift
swift Swift/1-Two-Sum/1-Two-Sum.swift
```
