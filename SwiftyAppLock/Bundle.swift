import UIKit

extension Bundle {
    
    static var appLock: Bundle {
        let bundleUrl = Bundle(for: AppLock.self)
            .url(forResource: "SwiftyAppLock", withExtension: "bundle")!
        
        return Bundle(url: bundleUrl)!
    }
}

