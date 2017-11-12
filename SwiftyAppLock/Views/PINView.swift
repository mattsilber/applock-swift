import UIKit

open class PINView: UIView, UIKeyInput {
    
    fileprivate var theme: Theme = Theme()
    
    fileprivate var itemData: [String] = []
    fileprivate var itemLayers: [PINItemLayer] = []
    
    public var itemsFull: Bool {
        return items.count == theme.characterCount
    }
    
    public var items: String {
        return itemData.joined(separator: "")
    }
    
    public var hasText: Bool {
        return 0 < itemData.count
    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override var canBecomeFocused: Bool {
        return true
    }
    
    open func configure(theme: Theme) {
        self.theme = theme
        self.isUserInteractionEnabled = true
        self.contentMode = .redraw
        self.resetDrawPositions()
        
        addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(viewTapped)))
    }
    
    open func reset() {
        self.itemData = []
        self.resetDrawPositions()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        resetDrawPositions()
    }
    
    open func resetDrawPositions() {
        let itemRadius = frame.width * theme.radiusEnabled
        let itemDiameter = itemRadius * 2
        let containerWidth = (CGFloat(theme.characterCount) * itemDiameter) + (theme.spacing * CGFloat(theme.characterCount - 1))
        let startingCenterX = (self.bounds.midX) - (containerWidth / 2) + itemRadius + (theme.spacing / 2)
        
        self.itemLayers = (0..<theme.characterCount)
            .map({
                let index = CGFloat($0)
                
                return CGPoint(
                    x: startingCenterX + (itemDiameter * index) + (theme.spacing * index),
                    y: self.bounds.height / 2)
            })
            .map({
                PINItemLayer(
                    center: $0,
                    theme: self.theme,
                    redrawRequired: { [weak self] in
                        self?.setNeedsDisplay()
                    })
            })
        
        self.notifyTextChanged()
    }
    
    public func insertText(_ text: String) {
        text.characters.forEach({
            guard !self.itemsFull else { return }
            
            let element = String($0)
            
            self.itemData.append(element)
        })
        
        self.notifyTextChanged()
    }
    
    public func deleteBackward() {
        guard 0 < itemData.count else { return }
        
        self.itemData = itemData.take(
            fromIndex: 0,
            size: itemData.count - 1)
        
        self.notifyTextChanged()
    }
    
    public func notifyTextChanged() {
        itemLayers.enumerated()
            .forEach({
                guard let value = itemData.take(index: $0.offset) else {
                    $0.element.set(
                        value: theme.characterEmptyValue,
                        active: false)
                    
                    return
                }
                
                $0.element.set(
                    value: theme.characterMask ?? value,
                    active: true)
            })
        
        self.setNeedsDisplay()
    }
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(theme.backgroundColor.cgColor)
        context.fill(self.bounds)
        context.setShouldAntialias(true)
        
        itemLayers.forEach({
            $0.draw(withContext: context)
        })
    }
    
    @objc fileprivate func viewTapped() {
        becomeFirstResponder()
    }
    
    public class Theme {
        
        public var backgroundColor: UIColor = .red
        
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
        public var characterEmptyValue: String = "-"
        public var characterCount: Int = 4
    }
}
