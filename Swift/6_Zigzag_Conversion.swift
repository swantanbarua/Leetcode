func convert(_ s: String, _ numRows: Int) -> String {
    
    if s == nil || numRows == 1 || s.count < numRows{
        return s
    }
    
    var rows = Array(repeating: [String](), count: numRows)
    var counter: Int = 0
    var canGoDown: Bool = false
    let arrayS: [Character] = Array(s)
    
    for (index, char) in arrayS.enumerated(){
        
        rows[counter].append(String(char))
        
        if counter == 0 || counter == numRows - 1{
            canGoDown = !canGoDown
        }
        
        counter = canGoDown ? counter + 1 : counter - 1
    }
    
    let result = rows.flatMap() {$0}
    return result.joined(separator: "")
}
