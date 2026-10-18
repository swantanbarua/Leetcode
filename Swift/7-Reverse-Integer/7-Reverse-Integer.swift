//
//  7-Reverse-Integer.swift
//  LeetCode 7. Reverse Integer  —  Medium
//  https://leetcode.com/problems/reverse-integer/
//
//  Status: Accepted
//

// MARK: - Problem
//
//  Given a signed 32-bit integer x, return x with its digits reversed. If
//  reversing x causes the value to go outside the signed 32-bit integer
//  range [-2^31, 2^31 - 1], then return 0.
//
//  Assume the environment does not allow you to store 64-bit integers
//  (signed or unsigned).
//
//  Example 1:
//      Input:  x = 123
//      Output: 321
//
//  Example 2:
//      Input:  x = -123
//      Output: -321
//
//  Example 3:
//      Input:  x = 120
//      Output: 21
//
//  Constraints:
//      -2^31 <= x <= 2^31 - 1

// MARK: - Approach
//
//  Move the digits across one at a time, from the end of x to the end of
//  the answer:
//
//      remainingNumber:  123  →  12  →  1  →  0
//      reversed:           0  →   3  → 32  → 321
//
//  Each round:
//      lastDigit = remainingNumber % 10     the leftover after dividing by 10
//      remainingNumber /= 10                Int division drops that digit
//      reversed = reversed * 10 + lastDigit shift left, add on the right
//
//  Negative numbers need no extra code: in Swift, -123 % 10 is -3 and
//  -123 / 10 is -12, so the minus sign travels with every digit. The loop
//  runs while remainingNumber != 0 (not > 0) so negatives are visited too.
//
//  Overflow is caught BEFORE the multiply, so no value past 32 bits is ever
//  stored. If reversed is already above Int32.max / 10 (214748364) or below
//  Int32.min / 10 (-214748364), multiplying by 10 would leave the range, so
//  return 0. Equal to 214748364 is safe: the digit added last is the first
//  digit of a 10-digit 32-bit input, which is only ever 1 or 2.
//
//  Time:  O(log |x|) — one round per digit, at most 10
//  Space: O(1)       — three small variables

// MARK: - Solution

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
