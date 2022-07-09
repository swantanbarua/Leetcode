func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
    if nums1.count > nums2.count{
        return findMedianSortedArrays(nums2, nums1)
    }
    
    var left: Int = 0
    var right: Int = nums1.count
    
    while left <= right{
        
        let posX: Int = left + (right - left) / 2
        let posY: Int = (nums1.count + nums2.count + 1) / 2 - posX
        
        let leftX: Int = posX == 0 ? Int.min : nums1[posX - 1]
        let leftY: Int = posY == 0 ? Int.min : nums2[posY - 1]
        let rightX: Int = posX == nums1.count ? Int.max : nums1[posX]
        let rightY: Int = posY == nums2.count ? Int.max : nums2[posY]
        
        if leftX <= rightY && leftY <= rightX{
            
            return (nums1.count + nums2.count) % 2 == 0 ? Double(Double(max(leftX, leftY)) + Double(min(rightX, rightY))) / 2 : Double(max(leftX, leftY))
        }
        
        if leftX > rightY{
            right = posX - 1
        }
        
        else{
            left = posX + 1
        }
    }
    
    return 0.0
}
