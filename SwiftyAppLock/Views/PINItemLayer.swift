import UIKit

class PINItemLayer: CALayer {
    
    fileprivate var center: CGPoint = CGPoint.zero
    fileprivate var theme: PINView.Theme?
    
    fileprivate var radiusEnabled: CGFloat {
        return UIScreen.main.bounds.width * (theme?.radiusEnabled ?? 30)
    }
    
    fileprivate var radiusDisabled: CGFloat {
        return UIScreen.main.bounds.width * (theme?.radiusDisabled ?? 12)
    }
    
    fileprivate var radiusRangePercent: CGFloat = 0
    fileprivate var radius: CGFloat {
        return radiusDisabled + ((radiusEnabled - radiusDisabled) * radiusRangePercent)
    }
    
    fileprivate var color: UIColor {
        guard let theme = theme else { return UIColor.blue }
        
        var disabledValues: [CGFloat] = theme.itemBackgroundColorDisabled.componentsARGB()
        var enabledValues: [CGFloat] = theme.itemBackgroundColorEnabled.componentsARGB()
        
        return UIColor(
            red: disabledValues[1] + ((enabledValues[1] - disabledValues[1]) * radiusRangePercent),
            green: disabledValues[2] + ((enabledValues[2] - disabledValues[2]) * radiusRangePercent),
            blue: disabledValues[3] + ((enabledValues[3] - disabledValues[3]) * radiusRangePercent),
            alpha: disabledValues[0] + ((enabledValues[0] - disabledValues[0]) * radiusRangePercent))
    }
    
    fileprivate var font: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            guard let theme = theme else { return }
            
            fontAttributes = [
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.foregroundColor: theme.textColorEnabled,
            ]
        }
    }
    fileprivate var fontAttributes: [NSAttributedStringKey: Any] = [:]
    
    fileprivate var stateAnimationStart: CFTimeInterval?
    fileprivate var stateAnimationRadiusStart: CGFloat = 1
    fileprivate var stateAnimationRadiusTarget: CGFloat = 1
    
    var value: String = "" {
        didSet { setNeedsDisplay() }
    }
    
    convenience init(
        center: CGPoint,
        theme: PINView.Theme) {
        self.init()
        
        self.center = center
        self.theme = theme
        self.font = theme.font
    }
    
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override func draw(in ctx: CGContext) {
        ctx.setFillColor(color.cgColor)
        
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true)
        
        path.fill()
        
        (value as NSString)
            .draw(at: center, withAttributes: fontAttributes)
    }
    
    @objc func stateAnimationUpdate(_ link: CADisplayLink) {
        guard let theme = theme,
            let animationStart = stateAnimationStart else { return }
        
        let linkTime = CGFloat((link.timestamp - animationStart) / theme.stateAnimationDurationSeconds)
        
        guard linkTime < 1 else {
            self.radiusRangePercent = stateAnimationRadiusTarget
            
            link.remove(from: .current, forMode: .commonModes)
            link.invalidate()
            
            return
        }
        
        self.radiusRangePercent = stateAnimationRadiusStart + (CGFloat(Darwin.atan(Float(linkTime) * 1.56)) * (stateAnimationRadiusTarget - stateAnimationRadiusStart))
        self.setNeedsDisplay()
    }
    
    func set(value: String, active: Bool) {
        self.value = value
        self.stateAnimationRadiusStart = radiusRangePercent
        self.stateAnimationRadiusTarget = active ? 1 : 0
        
        let link = CADisplayLink(
            target: self,
            selector: #selector(stateAnimationUpdate(_:)))
        
        link.add(to: .current, forMode: .commonModes)
    }
}
