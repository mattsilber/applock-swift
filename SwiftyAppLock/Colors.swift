import UIKit

extension UIColor {
    
    convenience init(hexRRGGBB: String) {
        var rgbValue: UInt32 = 0
        
        let colorGroup = hexRRGGBB.matching(withRegex: "#([a-fA-F0-9]{6})")[0][1]
        
        Scanner(string: colorGroup)
            .scanHexInt32(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
            alpha: 1)
    }
    
    func componentsARGB() -> [CGFloat] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [ a, r, g, b]
    }
}

fileprivate extension String {
    
    func matching(withRegex pattern: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        
        let casted = self as NSString
        let results = regex.matches(in: self, options: [], range: NSMakeRange(0, casted.length))
        
        return results.map({ result in
            return (0..<result.numberOfRanges).compactMap({
                let range = result.range(at: $0)
                
                return range.location == NSNotFound
                    ? nil
                    : casted.substring(with: range)
            })
        })
    }
}
