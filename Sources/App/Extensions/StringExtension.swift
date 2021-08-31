//
//  StringExtension.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation
import CryptoKit

extension Data {
    func hash(secretString: String) -> String {
        let key = SymmetricKey(data: secretString.data(using: .utf8)!)
        let signature = HMAC<SHA256>.authenticationCode(for: self, using: key)
        return Data(signature).map { String(format: "%02hhx", $0) }.joined()
    }
}
