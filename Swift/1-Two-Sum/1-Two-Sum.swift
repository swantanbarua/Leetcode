//
//  1-Two-Sum.swift
//  LeetCode 1. Two Sum  —  Easy
//  https://leetcode.com/problems/two-sum/
//
//  Status: Accepted
//

// MARK: - Problem
//
//  You are given an array of integers `nums` and an integer `target`,
//  return indices of the two numbers such that they add up to `target`.
//
//  You may assume that each input would have exactly one solution,
//  and you may not use the same element twice.
//
//  You can return the answer in any order.
//
//  Example 1:
//      Input:  nums = [2,7,11,15], target = 9
//      Output: [0,1]
//      Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].
//
//  Example 2:
//      Input:  nums = [3,2,4], target = 6
//      Output: [1,2]
//
//  Example 3:
//      Input:  nums = [3,3], target = 6
//      Output: [0,1]
//
//  Constraints:
//      2 <= nums.length <= 10^4
//      -10^9 <= nums[i] <= 10^9
//      -10^9 <= target <= 10^9
//      Only one valid answer exists.
//
//  Follow-up:
//      Can you come up with an algorithm that is less than O(n^2) time complexity?

// MARK: - Approach
//
//  One-pass hash map.
//
//  Standing on `num`, the partner is not "some number that works" — it is exactly
//  one value: target - num. So the question stops being "find a pair" (a search)
//  and becomes "have I already seen this one value?" (a lookup).
//
//  `seen` maps  value -> index, because we search by value and must return an index.
//
//  The lookup happens BEFORE the insert. That ordering is the algorithm:
//  `seen` then only ever holds elements to the LEFT of the current one, so any hit
//  is guaranteed to be a different element. No "don't reuse the same index" check
//  is needed, and [3,3] still returns [0,1] — same value, different positions.
//
//  Time:  O(n)  — one pass, O(1) average per dictionary lookup/insert
//  Space: O(n)  — worst case every element lands in the map

// MARK: - Solution

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
