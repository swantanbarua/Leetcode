//
//  3-Longest-Substring-Without-Repeating-Characters.swift
//  LeetCode 3. Longest Substring Without Repeating Characters  —  Medium
//  https://leetcode.com/problems/longest-substring-without-repeating-characters/
//
//  Status: Accepted
//

// MARK: - Problem
//
//  Given a string s, find the length of the longest substring without
//  duplicate characters.
//
//  Example 1:
//      Input:  s = "abcabcbb"
//      Output: 3
//      Explanation: The answer is "abc", with the length of 3. Note that
//      "bca" and "cab" are also correct answers.
//
//  Example 2:
//      Input:  s = "bbbbb"
//      Output: 1
//      Explanation: The answer is "b", with the length of 1.
//
//  Example 3:
//      Input:  s = "pwwkew"
//      Output: 3
//      Explanation: The answer is "wke", with the length of 3.
//      Notice that the answer must be a substring, "pwke" is a subsequence
//      and not a substring.
//
//  Constraints:
//      0 <= s.length <= 10^5
//      s consists of English letters, digits, symbols and spaces.

// MARK: - Approach
//
//  Sliding window with a "last seen" notebook.
//
//  Keep a window chars[left...right] that never contains a repeat. Slide
//  `right` forward one character at a time. Before admitting chars[right],
//  ask the notebook where that character was last seen:
//
//      if it was seen at index prev AND prev >= left    (inside the window)
//          left = prev + 1                              (jump past the old copy)
//
//  Then record lastSeen[chars[right]] = right and measure the window:
//  right - left + 1. Keep the biggest measurement seen.
//
//  The `prev >= left` check matters. A character seen BEFORE the window
//  (e.g. the first "a" in "abba" once left has moved to 2) is stale and must
//  not pull `left` backwards.
//
//  The notebook write happens AFTER the check. Writing first would make the
//  current character look like its own repeat.
//
//  `Array(s)` is used so characters can be indexed by Int; Swift's String
//  indices are not integers.
//
//  Time:  O(n)  — `right` visits each index once; `left` only moves forward
//  Space: O(k)  — one notebook entry per distinct character (bounded alphabet, so ~O(1))

// MARK: - Solution

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
