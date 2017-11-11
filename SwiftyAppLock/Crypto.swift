import Foundation
import CommonCrypto

public class Crypto {
    
    public enum Mode {
        
        case sha1
    }
    
    public static func encrypt(string: String, withMode mode: Mode) -> String? {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else { return nil }
        
        return encrypt(data: data, withMode: mode)
            .map({ String(format: "%02x", UInt8($0)) })
            .joined()
    }
    
    public static func encrypt(data: Data, withMode mode: Mode) -> Data {
        var bytes: [UInt8]
        
        switch mode {
        case .sha1:
            bytes = Array(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            
            data.withUnsafeBytes({
                _ = CC_SHA1($0, CC_LONG(data.count), &bytes)
            })
        }
        
        return Data(bytes: bytes)
    }
}
