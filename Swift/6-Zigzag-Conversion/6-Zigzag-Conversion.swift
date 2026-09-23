//
//  6-Zigzag-Conversion.swift
//  LeetCode 6. Zigzag Conversion  —  Medium
//  https://leetcode.com/problems/zigzag-conversion/
//
//  Status: Accepted
//

// MARK: - Problem
//
//  The string "PAYPALISHIRING" is written in a zigzag pattern on a given
//  number of rows like this:
//
//      P   A   H   N
//      A P L S I I G
//      Y   I   R
//
//  And then read line by line: "PAHNAPLSIIGYIR"
//
//  Write the code that will take a string and make this conversion given a
//  number of rows.
//
//  Example 1:
//      Input:  s = "PAYPALISHIRING", numRows = 3
//      Output: "PAHNAPLSIIGYIR"
//
//  Example 2:
//      Input:  s = "PAYPALISHIRING", numRows = 4
//      Output: "PINALSIGYAHRPI"
//      Explanation:
//          P     I    N
//          A   L S  I G
//          Y A   H R
//          P     I
//
//  Example 3:
//      Input:  s = "A", numRows = 1
//      Output: "A"
//
//  Constraints:
//      1 <= s.length <= 1000
//      s consists of English letters (lower-case and upper-case), ',' and '.'.
//      1 <= numRows <= 1000

// MARK: - Approach
//
//  Simulate the zigzag with one "shelf" (string) per row.
//
//  Walk the letters left to right. Drop each one on the shelf `currentRow`
//  points at, then move one row down or up. The row number bounces between
//  the top (0) and the bottom (numRows - 1):
//
//      letter:  P  A  Y  P  A  L  I  S  H  I  R  I  N  G
//      row:     0  1  2  1  0  1  2  1  0  1  2  1  0  1
//
//  Whenever we land on the top or bottom row, flip `goingDown`. It starts
//  as FALSE because the very first letter lands on row 0, which flips it to
//  true before the first move. Starting at true would send the first move
//  up to row -1.
//
//  At the end, glue the shelves together top to bottom.
//
//  With one row the top is also the bottom, so the direction flips every
//  letter and `currentRow` walks off the end (rows[1] on "AB"). One row
//  means the word is unchanged, so return it straight away.
//
//  Time:  O(n) — each letter is placed once, then one join
//  Space: O(n) — the shelves hold every letter once

// MARK: - Solution

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
