# LeetCode — Swift

My LeetCode solutions in Swift, each with a full step-by-step explanation.

The goal here is **not** to collect accepted submissions. It's to be able to re-derive every
solution from scratch months later. So each problem gets the reasoning that led to the code —
in plain language — not just the code.

## How this is organised

Every problem lives in its own folder, containing:

- **`README.md`** — the problem, then the solution explained step by step in simple terms,
  ending with the time and space complexity.
- **`<n>-<Problem-Name>.swift`** — the accepted solution, with the problem statement and
  approach summarised in comments.

```
Leetcode/
└── Swift/
    └── 1-Two-Sum/
        ├── README.md
        └── 1-Two-Sum.swift
```

## Solved

| # | Problem | Difficulty | Topic | Solution | Explanation |
|---|---------|-----------|-------|----------|-------------|
| 1 | [Two Sum](https://leetcode.com/problems/two-sum/) | Easy | Hash Map | [Swift](Swift/1-Two-Sum/1-Two-Sum.swift) | [README](Swift/1-Two-Sum/) |

## Running a solution locally

Each file is standalone. Add a couple of lines at the bottom and run it directly — no Xcode
project needed:

```bash
swift Swift/1-Two-Sum/1-Two-Sum.swift
```
