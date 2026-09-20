//
//  4-Median-of-Two-Sorted-Arrays.swift
//  LeetCode 4. Median of Two Sorted Arrays  —  Hard
//  https://leetcode.com/problems/median-of-two-sorted-arrays/
//
//  Status: Accepted
//

// MARK: - Problem
//
//  Given two sorted arrays nums1 and nums2 of size m and n respectively,
//  return the median of the two sorted arrays.
//
//  The overall run time complexity should be O(log (m+n)).
//
//  Example 1:
//      Input:  nums1 = [1,3], nums2 = [2]
//      Output: 2.00000
//      Explanation: merged array = [1,2,3] and median is 2.
//
//  Example 2:
//      Input:  nums1 = [1,2], nums2 = [3,4]
//      Output: 2.50000
//      Explanation: merged array = [1,2,3,4] and median is (2 + 3) / 2 = 2.5.
//
//  Constraints:
//      nums1.length == m
//      nums2.length == n
//      0 <= m <= 1000
//      0 <= n <= 1000
//      1 <= m + n <= 2000
//      -10^6 <= nums1[i], nums2[i] <= 10^6

// MARK: - Approach
//
//  Binary search for the "cut", without merging.
//
//  Imagine the merged sorted array with a line through its middle. The left
//  side holds exactly half = (m + n + 1) / 2 numbers (the extra one goes left
//  when the total is odd). That one line is really two lines, one in each
//  array: take `takeFromNums1` numbers from the front of nums1 and
//  `takeFromNums2 = half - takeFromNums1` from the front of nums2.
//
//  Only takeFromNums1 is searched (binary search over 0...nums1Size). The
//  other amount is forced by the count. nums1 is made the shorter array first
//  so that `half - takeFromNums1` can never be negative or exceed nums2Size.
//
//  A cut is correct when everything on the left <= everything on the right.
//  Because each array is sorted, only the four numbers touching the line
//  matter, and only the two CROSS comparisons can fail:
//
//      nums1Left <= nums2Right  &&  nums2Left <= nums1Right
//
//  Int.min / Int.max stand in for a side that is empty, so an edge cut is
//  never rejected for a number that does not exist.
//
//      nums1Left > nums2Right  ->  nums1 gave too much  ->  high = takeFromNums1 - 1
//      otherwise               ->  nums2 gave too much  ->  low  = takeFromNums1 + 1
//
//  At the correct cut the median sits on the line:
//      odd total  -> maxLeft
//      even total -> (maxLeft + minRight) / 2
//
//  Time:  O(log(min(m, n)))  — binary search over cuts in the shorter array
//  Space: O(1)               — a handful of variables, no merged array

// MARK: - Solution

class Solution {
    func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
        
        if nums1.count > nums2.count {
            return findMedianSortedArrays(nums2, nums1)
        }

        let nums1Size = nums1.count
        let nums2Size = nums2.count
        let half = (nums1Size + nums2Size + 1) / 2

        var low = 0
        var high = nums1Size

        while low <= high {
            let takeFromNums1 = (low + high) / 2
            let takeFromNums2 = half - takeFromNums1

            let nums1Left = takeFromNums1 == 0 ? Int.min : nums1[takeFromNums1 - 1]
            let nums1Right = takeFromNums1 == nums1Size ? Int.max : nums1[takeFromNums1]
            let nums2Left = takeFromNums2 == 0 ? Int.min : nums2[takeFromNums2 - 1]
            let nums2Right = takeFromNums2 == nums2Size ? Int.max : nums2[takeFromNums2]

            if nums1Left <= nums2Right && nums2Left <= nums1Right {
                let maxLeft = max(nums1Left, nums2Left)
                let minRight = min(nums1Right, nums2Right)

                if (nums1Size + nums2Size) % 2 == 1 {
                    return Double(maxLeft)
                }

                return Double(maxLeft + minRight) / 2.0
            } else if nums1Left > nums2Right {
                high = takeFromNums1 - 1
            } else {
                low = takeFromNums1 + 1
            }
        }

        return 0.0
    }
}
