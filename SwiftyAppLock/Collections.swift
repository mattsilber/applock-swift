extension Array {
    
    func take(fromIndex: Int, size: Int) -> Array {
        guard fromIndex < count else { return [] }
        
        let endIndex = Swift.min(count, fromIndex + size)
        
        return Array(self[fromIndex..<endIndex])
    }
    
    func take(index: Int, defaultValue: Element? = nil) -> Element? {
        return -1 < index && index < count
            ? self[index]
            : defaultValue
    }
}
