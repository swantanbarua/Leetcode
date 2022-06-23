class Solution {
    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
        
        var dictionary = [Int: Int]()
        
        for index in 0..<nums.count{
            if dictionary.keys.contains(target - nums[index]){
                return [dictionary[target - nums[index]]!, index]
            }
            
            else{
                dictionary[nums[index]] = index
            }
        }
        
        return [-1, -1]
    }
}
