//
//  5-Longest-Palindromic-Substring.swift
//  LeetCode 5. Longest Palindromic Substring  —  Medium
//  https://leetcode.com/problems/longest-palindromic-substring/
//
//  Status: Accepted
//

// MARK: - Problem
//
//  Given a string s, return the longest palindromic substring in s.
//
//  Example 1:
//      Input:  s = "babad"
//      Output: "bab"
//      Explanation: "aba" is also a valid answer.
//
//  Example 2:
//      Input:  s = "cbbd"
//      Output: "bb"
//
//  Constraints:
//      1 <= s.length <= 1000
//      s consist of only digits and English letters.

// MARK: - Approach
//
//  Expand around every possible centre.
//
//  Every palindrome has a middle. Stand on each index as the middle, put a
//  left foot and a right foot there, and walk them outwards one box at a
//  time as long as both feet see the same letter and neither has fallen
//  off the array. When the walk stops the feet are standing on the two
//  letters that BROKE the match, so the palindrome is what sits between
//  them:
//
//      length = right - left - 1
//      start  = left + 1
//
//  Keep the longest one seen (bestStart / bestLength) and cut it out of the
//  array at the end.
//
//  Palindromes come in two shapes, so each centre is walked twice:
//
//      odd length  ("aba")  — feet start on the SAME box:   right = center
//      even length ("bb")   — feet start on NEIGHBOURS:     right = center + 1
//
//  With only the odd walk the feet are always an even distance apart and
//  can never land on two adjacent equal letters, so "bb" would be missed.
//
//  In the while condition the two boundary checks come BEFORE the letter
//  comparison so that chars[-1] / chars[count] is never read.
//
//  `Array(s)` is used so characters can be indexed by Int; Swift's String
//  indices are not integers.
//
//  Time:  O(n^2) — n centres x 2 shapes, each walk at most n steps
//  Space: O(n)   — the character array; otherwise a handful of integers

// MARK: - Solution

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
