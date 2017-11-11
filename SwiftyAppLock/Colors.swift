import UIKit

extension UIColor {
    
    func componentsARGB() -> [CGFloat] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [ a, r, g, b]
    }
}
