import UIKit

public class AppLock {
    
    public static let shared = AppLock()
    
    public var configs: Configs = Configs()
    public var theme: AppLockView.Theme = AppLockView.Theme()
    public var messages: Messages = Messages()
    
    fileprivate static let pinHashKey: String = "al__pin_data"
    fileprivate var pinHash: String? {
        get {
            return UserDefaults.standard
                .value(forKey: AppLock.pinHashKey) as? String
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: AppLock.pinHashKey)
        }
    }
    
    public var pinExists: Bool {
        return pinHash != nil
    }
    
    fileprivate var currentUnlockAttempt: Int = 0
    public var unlockDurationSeconds: TimeInterval = 60 * 15
    public var unlockRequired: Bool {
        return pinExists && unlockDurationSeconds < Date().timeIntervalSince1970 - (lastUnlockDate?.timeIntervalSince1970 ?? 0)
    }
    
    fileprivate static let lastUnlockKey: String = "al__pin_last_unlock_date"
    fileprivate var lastUnlockDate: Date? {
        get {
            return UserDefaults.standard
                .value(forKey: AppLock.lastUnlockKey) as? Date
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: AppLock.lastUnlockKey)
        }
    }
    
    fileprivate static let unlockRetryLockedDateKey: String = "al__pin_retry_locked_date"
    fileprivate var unlockRetryLockedAtDate: Date? {
        get {
            return UserDefaults.standard
                .value(forKey: AppLock.unlockRetryLockedDateKey) as? Date
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: AppLock.unlockRetryLockedDateKey)
        }
    }
    
    public var unlockRetryAllowedAtDate: Date? {
        guard let lockedAt = unlockRetryLockedAtDate else { return nil }
        
        return lockedAt.addingTimeInterval(configs.lockoutDurationSeconds)
    }
    
    public var unlockRetryLimitExceeded: Bool {
        return currentUnlockAttempt < configs.maxUnlockAttempts
    }
    
    public var unlockRetryAllowed: Bool {
        return unlockRetryLimitExceeded && (unlockRetryAllowedAtDate?.timeIntervalSince1970 ?? 0) < Date().timeIntervalSince1970
    }
    
    public var limitExceededMessage: String {
        guard let date = unlockRetryAllowedAtDate else { return "Retry limit exceeded" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = messages.errorRetryLimitExceededDateFormat
        
        return String(
            format: messages.errorRetryLimitExceeded,
            arguments: [ dateFormatter.string(from: date) ])
    }
    
    fileprivate init() { }
    
    @discardableResult public func attach(
        to viewController: UIViewController,
        withWindowStyle windowStyle: AppLockView.WindowStyle = .dialog,
        pinNotPresent: (() -> Void)? = nil,
        unlockAbortRequested: @escaping (AppLockView) -> Void,
        unlockRetryExceeded: ((AppLockView, Date?) -> Void)? = nil,
        unlockSuccess: (() -> Void)? = nil) -> AppLockView? {
        
        guard pinExists else {
            pinNotPresent?()
            return nil
        }
        
        let view = AppLockView.attach(
            to: viewController,
            theme: theme,
            windowStyle: windowStyle,
            positiveAction: { view, pin in
                view.resetItems()
                
                guard AppLock.shared.unlockRetryAllowed else { return }
                
                guard AppLock.shared.pinMatches(unencryptedPin: pin) else {
                    AppLock.shared.currentUnlockAttempt += 1
                    
                    guard !AppLock.shared.unlockRetryLimitExceeded else {
                        AppLock.shared.unlockRetryLockedAtDate = Date()
                        
                        view.set(instructions: AppLock.shared.limitExceededMessage)
                        unlockRetryExceeded?(view, AppLock.shared.unlockRetryAllowedAtDate)
                        
                        return
                    }
                    
                    view.set(instructions: AppLock.shared.messages.errorMismatch)
                    
                    return
                }
                
                AppLock.shared.lastUnlockDate = Date()
                AppLock.shared.currentUnlockAttempt = 0
                
                unlockSuccess?()
            },
            negativeAction: { view in
                unlockAbortRequested(view)
            })
        
        guard !unlockRetryLimitExceeded else {
            view.set(instructions: AppLock.shared.limitExceededMessage)
            unlockRetryExceeded?(view, AppLock.shared.unlockRetryAllowedAtDate)
            
            return view
        }
        
        view.set(instructions: messages.unlock)
        
        return view
    }
    
    @discardableResult public func create(
        on viewController: UIViewController,
        withWindowStyle windowStyle: AppLockView.WindowStyle = .dialog,
        instructionMessage: String = AppLock.shared.messages.create,
        creationAborted: (() -> Void)?,
        creationError: ((String) -> Void)?,
        pinCreated: @escaping (String) -> Void) -> AppLockView? {
        
        guard !pinExists else {
            creationError?(messages.errorPinAlreadyExists)
            return nil
        }
        
        let view = AppLockView.attach(
            to: viewController,
            theme: theme,
            windowStyle: windowStyle,
            positiveAction: { view1, pin1 in
                view1.resetItems()
                
                var errors: [String] = []
                
                if pin1.characters.count != AppLock.shared.configs.pinLength {
                    errors.append(AppLock.shared.messages.errorInsufficientDigits)
                }
                
                let firstPin = Crypto.encrypt(
                    string: pin1,
                    withMode: AppLock.shared.configs.encryption)
                
                if firstPin == nil {
                    errors.append(AppLock.shared.messages.errorInsufficientDigits)
                }
                
                guard errors.count < 1 else {
                    AppLock.shared.create(
                        on: viewController,
                        withWindowStyle: windowStyle,
                        instructionMessage: errors.joined(separator: "\n"),
                        creationAborted: creationAborted,
                        creationError: creationError,
                        pinCreated: pinCreated)
                    return
                }
                
                AppLockView.attach(
                    to: viewController,
                    theme: AppLock.shared.theme,
                    windowStyle: windowStyle,
                    positiveAction: { view2, pin2 in
                        let secondPin = Crypto.encrypt(
                            string: pin1,
                            withMode: AppLock.shared.configs.encryption)
                        
                        guard let first = firstPin,
                            let second = secondPin,
                            first == second else {
                                AppLock.shared.create(
                                    on: viewController,
                                    withWindowStyle: windowStyle,
                                    instructionMessage: AppLock.shared.messages.errorCreateMismatch,
                                    creationAborted: creationAborted,
                                    creationError: creationError,
                                    pinCreated: pinCreated)
                                return
                        }
                        
                        AppLock.shared.pinHash = first
                        
                        view2.dismiss(withCompletion: {
                            pinCreated(first)
                        })
                    },
                    negativeAction: { view2 in
                        view2.dismiss(withCompletion: creationAborted)
                    })
            },
            negativeAction: { view in
                view.dismiss(withCompletion: creationAborted)
            })
        
        view.set(instructions: messages.create)
        
        return view
    }
    
    fileprivate func pinMatches(unencryptedPin: String) -> Bool {
        guard let stored = pinHash else { return false }
        
        return stored == Crypto.encrypt(string: unencryptedPin, withMode: configs.encryption)
    }
    
    public class Configs {
        
        public var encryption: Crypto.Mode = .sha1
        public var pinLength: Int = 4
        public var maxUnlockAttempts: Int = 5
        public var lockoutDurationSeconds: Double = 60 * 5
    }
    
    public class Messages {
        
        public var create: String = "Create a PIN to lock this app"
        public var createConfirm: String = "Re-enter PIN to confirm"
        
        public var unlock: String = "Enter your PIN to unlock"
        
        public var errorNoPin: String = "There is nothing to unlock"
        public var errorMismatch: String = "PIN does not match"
        public var errorCreateMismatch: String = "PIN does not match. Re-enter"
        public var errorInsufficientDigits: String = "Incorrect PIN length"
        public var errorRetryLimitExceeded: String = "You failed too many times. Please try again after %1$@"
        public var errorRetryLimitExceededDateFormat: String = "MM dd, yyyy hh:mm aa"
        public var errorPinAlreadyExists: String = "A PIN already exists"
    }
}
