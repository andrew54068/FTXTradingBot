//
//  FTXRequestHeaderPlugin.swift
//
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation
import NIOHTTP1

struct FTXRequestHeaderPlugin {
    let apiKey: String
    let apiSecret: String
    let subAccountName: String?

    init(
        apiKey: String,
        apiSecret: String,
        subAccountName: String? = nil
    ) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.subAccountName = subAccountName
    }

    func prepare(endpoint: Endpoint) -> Endpoint {
        let timestamp = "\(Int(Date().timeIntervalSince1970 * 1000))"
        let method = endpoint.method.rawValue
        let path = endpoint.path
        let signaturePayload = "\(timestamp)\(method)\(path)"
        var signaturePayloadData = Data(signaturePayload.utf8)
        signaturePayloadData.append(endpoint.httpBody)
        let signature = signaturePayloadData.hash(secretString: apiSecret)
        var newEndpoint = endpoint.adding(newHTTPHeaderFields: [
            "FTX-SIGN": signature,
            "FTX-TS": timestamp,
            "FTX-KEY": apiKey,
        ])
        if let subAccount = subAccountName {
            newEndpoint = newEndpoint.addingValue(subAccount, newHTTPHeaderFields: "FTX-SUBACCOUNT")
        }
        return newEndpoint
    }
}
