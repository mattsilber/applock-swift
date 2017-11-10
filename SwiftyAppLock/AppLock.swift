import Foundation

public class AppLock {
    
    public static let shared = AppLock()
    
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
    fileprivate var maxUnlockAttempts: Int = 5
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
}
