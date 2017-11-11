import UIKit

open class PINView: UIView, UIKeyInput {
    
    var theme: Theme = Theme()
    
    fileprivate var itemData: [String] = []
    fileprivate var itemCenters: [CGPoint] = []
    
    var itemsFull: Bool {
        return items.count == theme.characterCount
    }
    
    var items: String {
        return itemData.joined(separator: "")
    }
    
    public var hasText: Bool {
        return 0 < itemData.count
    }
    
    open func reset() {
        self.itemData = []
        self.resetDrawPositions()
        self.setNeedsDisplay()
    }
    
    open func resetDrawPositions() {
        let itemRadius = UIScreen.main.bounds.width * theme.radiusEnabled
        let itemDiameter = itemRadius * 2
        let containerWidth = CGFloat(theme.characterCount) * itemDiameter + (theme.spacing * CGFloat(theme.characterCount - 1))
        let startingCenterX = (UIScreen.main.bounds.width / 2) - (containerWidth / 2) + itemRadius
        
        self.itemCenters = (0..<theme.characterCount)
            .map({
                let index = CGFloat($0)
                
                return CGPoint(
                    x: startingCenterX + (itemDiameter * index) + (theme.spacing * index),
                    y: self.bounds.height / 2)
            })
    }
    
    public func insertText(_ text: String) {
        text.characters.forEach({
            guard !self.itemsFull else { return }
            
            let element = String($0)
            
            self.itemData.append(element)
        })
    }
    
    public func deleteBackward() {
        guard 0 < itemData.count else { return }
        
        self.itemData = itemData.take(
            fromIndex: 0,
            size: itemData.count - 1)
    }
    
    public class Theme {
        
        public var stateAnimationDurationSeconds: Double = 0.275
        public var itemBackgroundColorEnabled: UIColor = .blue
        public var itemBackgroundColorDisabled: UIColor = .blue
        
        public var textColorEnabled: UIColor = .white
        public var textColorDisabled: UIColor = .white
        public var fontSize: CGFloat = 16
        public var fontName: String = "Helvetica Neue"
        public var font: UIFont {
            return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        }
        
        public var radiusEnabled: CGFloat = 0.075
        public var radiusDisabled: CGFloat = 0.025
        
        public var spacing: CGFloat = 0.0325
        public var characterMask: String? = "*"
        public var characterCount: Int = 4
    }
}
