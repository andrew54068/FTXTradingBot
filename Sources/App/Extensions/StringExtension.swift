//
//  StringExtension.swift
//
//
//  Created by Andrew Wang on 2021/8/30.
//

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    import CryptoKit
#else
    import Crypto
#endif
import Foundation

extension Data {
    func hash(secretString: String) -> String {
        let key = SymmetricKey(data: secretString.data(using: .utf8)!)
        let signature = HMAC<SHA256>.authenticationCode(for: self, using: key)
        return Data(signature).map { String(format: "%02hhx", $0) }.joined()
    }
}
