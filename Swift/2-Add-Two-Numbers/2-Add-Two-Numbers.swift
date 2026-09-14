//
//  2-Add-Two-Numbers.swift
//  LeetCode 2. Add Two Numbers  —  Medium
//  https://leetcode.com/problems/add-two-numbers/
//
//  Status: Accepted
//

// MARK: - Problem
//
//  You are given two non-empty linked lists representing two non-negative
//  integers. The digits are stored in reverse order, and each of their nodes
//  contains a single digit. Add the two numbers and return the sum as a
//  linked list.
//
//  You may assume the two numbers do not contain any leading zero, except
//  the number 0 itself.
//
//  Example 1:
//      Input:  l1 = [2,4,3], l2 = [5,6,4]
//      Output: [7,0,8]
//      Explanation: 342 + 465 = 807.
//
//  Example 2:
//      Input:  l1 = [0], l2 = [0]
//      Output: [0]
//
//  Example 3:
//      Input:  l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]
//      Output: [8,9,9,9,0,0,0,1]
//
//  Constraints:
//      The number of nodes in each linked list is in the range [1, 100].
//      0 <= Node.val <= 9
//      It is guaranteed that the list represents a number that does not
//      have leading zeros.

// MARK: - Approach
//
//  Paper addition, one column per loop iteration.
//
//  The lists are stored in reverse, so the FIRST node of each list is the
//  ones digit — exactly where paper addition starts. Walk both lists from
//  the front with two pointers. At each column:
//
//      currentSum = digit1 + digit2 + carry        (a missing digit counts as 0)
//      write      currentSum % 10                  (the ones digit)
//      carry      currentSum / 10                  (the tens digit, 0 or 1)
//
//  The loop keeps going while EITHER list still has nodes OR a carry is left
//  over. That single condition handles lists of different lengths and the
//  extra final digit (9999999 + 9999 = 10009999 is one digit longer).
//
//  A dummy head node gives the first real node something to hang off.
//  `dummyNode` never moves, so it still marks the front of the answer at the
//  end; `dummyPointer` is a second reference to the same object that walks
//  forward as nodes are appended. Return `dummyNode.next` to skip the dummy.
//
//  Time:  O(max(m, n))  — one pass over the longer list, O(1) work per node
//  Space: O(max(m, n))  — the answer list itself; O(1) extra beyond that

// MARK: - ListNode (provided by LeetCode)

public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil; }
    public init(_ val: Int) { self.val = val; self.next = nil; }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
}

// MARK: - Solution

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
