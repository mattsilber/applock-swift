import UIKit

public class AppLockView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var pinView: PINView!
    
    @IBOutlet weak var positiveButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    
    var windowStyle: WindowStyle = .dialog {
        didSet { updateWindowTheme() }
    }
    
    var theme: Theme = Theme() {
        didSet {
            updateContentTheme()
            setNeedsDisplay()
        }
    }
    
    fileprivate var positiveAction: ((AppLockView, String) -> Void)?
    fileprivate var negativeAction: ((AppLockView) -> Void)?
    
    @discardableResult public static func attach(
        to viewController: UIViewController,
        theme: Theme? = nil,
        windowStyle: WindowStyle = .dialog,
        positiveAction: @escaping (AppLockView, String) -> Void,
        negativeAction: @escaping (AppLockView) -> Void) -> AppLockView {
        
        let view = aquireAppLockView(in: viewController)
        view.windowStyle = windowStyle
        view.theme = theme ?? view.theme
        view.positiveAction = positiveAction
        view.negativeAction = negativeAction
        view.resetItems()
        
        view.pinView.becomeFirstResponder()
        
        return view
    }
    
    fileprivate static func aquireAppLockView(in viewController: UIViewController) -> AppLockView {
        if let existing = viewController.view
            .subviews
            .flatMap({ $0 as? AppLockView })
            .first {
            return existing
        }
        
        let view = instantiateNib()
        view.frame = viewController.view.frame
        viewController.view.addSubview(view)
        
        return view
    }
    
    public class func instantiateNib() -> AppLockView {
        return Bundle.appLock
            .loadNibNamed("AppLockView", owner: self, options: nil)?.first as! AppLockView
    }
    
    public func set(instructions: String) {
        self.instructionsLabel.text = instructions
    }
    
    open func resetItems() {
        self.pinView.reset()
        self.setNeedsDisplay()
    }
    
    func updateWindowTheme() {
        containerView.backgroundColor = theme.containerBackgroundColor
        containerView.layer.cornerRadius = theme.containerCornerRadius
        
        switch windowStyle {
        case .dialog:
            backgroundColor = UIColor.black.withAlphaComponent(0.45)
        case .fullscreen:
            backgroundColor = theme.containerBackgroundColor
        }
    }
    
    func updateContentTheme() {
        instructionsLabel.textColor = theme.instructionsTextColor
        instructionsLabel.font = UIFont(name: theme.fontName, size: theme.instructionsFontSize)
            ?? UIFont.systemFont(ofSize: theme.instructionsFontSize)
        
        pinView.configure(theme: theme.items)
        
        positiveButton.setTitleColor(theme.buttonPositiveTextColor, for: .normal)
        positiveButton.setTitle(AppLock.shared.messages.buttonPositive, for: .normal)
        positiveButton.layer.cornerRadius = positiveButton.frame.height / 2
        positiveButton.layer.borderColor = theme.buttonPositiveTextColor.cgColor
        positiveButton.layer.borderWidth = theme.buttonBorderWidth
        
        negativeButton.setTitleColor(theme.buttonNegativeTextColor, for: .normal)
        negativeButton.setTitle(AppLock.shared.messages.buttonNegative, for: .normal)
        negativeButton.layer.cornerRadius = negativeButton.frame.height / 2
        negativeButton.layer.borderColor = theme.buttonNegativeTextColor.cgColor
        negativeButton.layer.borderWidth = theme.buttonBorderWidth
    }
    
    @IBAction open func positiveButtonTapped() {
        positiveAction?(self, pinView.items)
    }
    
    @IBAction open func negativeButtonTapped() {
        negativeAction?(self)
    }
    
    open func dismiss(withCompletion completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.375,
            animations: {
                self.alpha = 0
            },
            completion: { [weak self] finished in
                self?.removeFromSuperview()
                completion?()
            })
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pinView.becomeFirstResponder()
    }
    
    public enum WindowStyle {
        
        case dialog
        case fullscreen
    }
    
    open class Theme {
        
        public var containerBackgroundColor: UIColor = .white
        public var containerCornerRadius: CGFloat = 6
        
        public var instructionsTextColor: UIColor = UIColor(hexRRGGBB: "#95a5a6")
        public var instructionsFontSize: CGFloat = 16
        
        public var buttonBorderWidth: CGFloat = 1
        public var buttonPositiveTextColor: UIColor = UIColor(hexRRGGBB: "#3498db")
        public var buttonNegativeTextColor: UIColor = UIColor(hexRRGGBB: "#95a5a6")
        
        public var fontName: String = "Helvetica Neue"
        
        public var items: PINView.Theme = PINView.Theme()
        
        public init() { }
    }
}
