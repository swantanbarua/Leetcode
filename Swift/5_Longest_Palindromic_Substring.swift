func longestPalindrome(_ s: String) -> String {
    
    if s == nil || s.count < 1{
        return ""
    }
    
    var start: Int = 0
    var end: Int = 0
    var charArray: [Character] = Array(s)
    
    for index in 0..<charArray.count{
        
        let len1: Int = expandFromMiddle(charArray, index, index)
        let len2: Int = expandFromMiddle(charArray, index, index + 1)
        let len: Int = max(len1, len2)
        
        if len > end - start{
            
            start = index - (len - 1) / 2
            end = index + (len / 2)
        }
    }
    
    var result: [Character] = []
    for index in start...end{
        
        result.append(charArray[index])
    }
    
    return String(result)
}

func expandFromMiddle(_ charArray: [Character], _ left: Int, _ right: Int) -> Int{
    
    if charArray == nil || left > right{
        return 0
    }
    
    var left: Int = left
    var right: Int = right
    
    while left >= 0 && right < charArray.count && charArray[left] == charArray[right]{
        
        left -= 1
        right += 1
    }
    
    return right - left - 1
}
