func lengthOfLongestSubstring(_ s: String) -> Int {
    
    if s == nil || s.count == 0{
        return 0
    }
    
    var result: [Character : Int] = [:]
    var lastDupIndex: Int = -1
    var maxSize: Int = 0
    var characterArray: [Character] = Array(s)
    
    for index in 0..<characterArray.count{
        if let lastIndex = result[characterArray[index]], lastDupIndex < lastIndex{
            lastDupIndex = lastIndex
        }
        
        maxSize = max(maxSize, index - lastDupIndex)
        result[characterArray[index]] = index
    }
    
    return maxSize
}
