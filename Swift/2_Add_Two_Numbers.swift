class Solution {
    func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
        
        var dummy: ListNode? = ListNode(-1)
        var current: ListNode? = dummy
        
        var carry: Int = 0
        var l1: ListNode? = l1
        var l2: ListNode? = l2
        
        while l1 != nil || l2 != nil || carry > 0{
            var sum: Int = carry
            let l1Val: Int = l1?.val ?? 0
            let l2Val: Int = l2?.val ?? 0
            sum = l1Val + l2Val + carry
            carry = sum / 10
            current?.next = ListNode(sum % 10)
            l1 = l1?.next
            l2 = l2?.next
            current = current?.next
        }
        
        return dummy?.next
    }
}
