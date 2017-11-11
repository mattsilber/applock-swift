import UIKit

public class AppLockView: UIView {
    
    @IBOutlet weak var pinView: PINView!
    
    var windowStyle: WindowStyle = .dialog
    var theme: Theme = Theme() {
        didSet { setNeedsDisplay() }
    }
    
    fileprivate var pinSubmissionRequested: (([String]) -> Void)?
    
    open func resetItems() {
        self.pinView.reset()
        self.setNeedsDisplay()
    }
    
    public enum WindowStyle {
        
        case dialog
        case fullscreen
    }
    
    public class Theme {
        
        public var containerBackgroundColor: UIColor = .white
        public var containerCornerRadius: CGFloat = 6
        
        public var instructionsTextColor: UIColor = .darkGray
        public var instructionsFontSize: CGFloat = 16
        
        public var fontName: String = "Helvetica Neue"
        
        public var items: PINView.Theme = PINView.Theme()
    }
    
}
