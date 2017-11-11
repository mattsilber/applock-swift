import Foundation

public class AppLock {
    
    public static let shared = AppLock()
    
    var configs: Configs = Configs()
    var messages: Messages = Messages()
    
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
    
    public var unlockDurationSeconds: TimeInterval = 60 * 15
    public var unlockRequired: Bool {
        return pinExists && unlockDurationSeconds < Date().timeIntervalSince1970 - (lastUnlock?.timeIntervalSince1970 ?? 0)
    }
    
    fileprivate static let lastUnlockKey: String = "al__pin_last_unlock_date"
    fileprivate var currentUnlockAttempt: Int = 0
    fileprivate var lastUnlock: Date? {
        get {
            return UserDefaults.standard
                .value(forKey: AppLock.lastUnlockKey) as? Date
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: AppLock.lastUnlockKey)
        }
    }
    
    fileprivate init() { }
    
    public class Configs {
        
        public var encryption: Crypto.Mode = .sha1
        public var pinLength: Int = 4
        public var maxUnlockAttempts: Int = 5
    }
    
    public class Messages {
        
        public var create: String = "Create a PIN to lock this app"
        public var createConfirm: String = "Re-enter PIN to confirm"
        
        public var unlock: String = "Enter your PIN to unlock"
        
        public var errorNoPin: String = "There is nothing to unlock"
        public var errorMismatch: String = "PIN does not match"
        public var errorInsufficientDigits: String = "Incorrect PIN length"
        public var errorRetryLimitExceeded: String = "You failed too many times. Please try again in %1$@"
    }
}
