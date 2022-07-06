//
//  2_Add_Two_Numbers.swift
//  Leetcode Solutions
//
//  Created by Swantan Barua on 06/07/22.
//

class Solution {
    func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
        
        // Creating our dummy linked list to save the result
        var dummy: ListNode? = ListNode(-1)
        // Pointer to our dummy linked list
        var current: ListNode? = dummy
        
        var carry: Int = 0
        
        // Storing the two lists in a separate variable since in Swift the parameters of a function are immutable
        var l1: ListNode? = l1
        var l2: ListNode? = l2
        
        while l1 != nil || l2 != nil || carry > 0{
            let l1Val: Int = l1?.val ?? 0
            let l2Val: Int = l2?.val ?? 0
            let totalSum: Int = l1Val + l2Val + carry
            
            carry = totalSum / 10
            current?.next = ListNode(totalSum % 10)
            l1 = l1?.next
            l2 = l2?.next
            current = current?.next
        }
        
        return dummy?.next
    }
}
