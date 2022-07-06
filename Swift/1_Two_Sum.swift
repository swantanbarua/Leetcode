//
//  1_Two_Sum.swift
//  Leetcode Solutions
//
//  Created by Swantan Barua on 06/07/22.
//

class Solution {
    func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
        
        // Create an empty dictionary to store the key value pairs
        var dictionary: [Int : Int] = [:]
        
        //  Check if difference of target and the current value  of the array exists in the dictionary
        
        for index in 0..<nums.count{
            if dictionary[target - nums[index]] != nil{
                return [dictionary[target - nums[index]]!, index]
            }
            
            // Store the value as key and it's corresponding index as key
            dictionary[nums[index]] = index
        }
        
        // If the no required pair exists
        return [-1, -1]
    }
}
