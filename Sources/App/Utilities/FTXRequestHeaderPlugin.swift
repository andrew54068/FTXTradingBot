//
//  FTXRequestHeaderPlugin.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation
import Moya
import SwiftyJSON
 
struct FTXRequestHeaderPlugin {
    
    let apiKey: String
    let apiSecret: String
    let subAccountName: String?
    
    init(apiKey: String,
         apiSecret: String,
         subAccountName: String? = nil) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.subAccountName = subAccountName
    }

    func prepare(_ request: URLRequest, method: Moya.Method, target: TargetType) -> URLRequest {
        let tokenTargetType: FTXSignatureTargetType
        if let multiTarget = target as? MultiTarget {
            guard let bloctoTokenTargetType = multiTarget.target as? FTXSignatureTargetType else { return request }
            tokenTargetType = bloctoTokenTargetType
        } else {
            guard let bloctoTokenTargetType = target as? FTXSignatureTargetType else { return request }
            tokenTargetType = bloctoTokenTargetType
        }

        var request = request
        
        let timestamp = "\(Int(tokenTargetType.currentTimestamp * 1000))"
        let method = tokenTargetType.method.rawValue
        let path = tokenTargetType.path
        let signaturePayload = "\(timestamp)\(method)\(path)"
        var signaturePayloadData = Data(signaturePayload.utf8)
        if let body = request.httpBody {
            signaturePayloadData.append(body)
        }
        let signature = signaturePayloadData.hash(secretString: apiSecret)
        request.addValue(signature, forHTTPHeaderField: "FTX-SIGN")
        request.addValue(timestamp, forHTTPHeaderField: "FTX-TS")
        request.addValue(apiKey, forHTTPHeaderField: "FTX-KEY")
        if let subAccount = subAccountName {
            request.addValue(subAccount, forHTTPHeaderField: "FTX-SUBACCOUNT")
        }
        return request
    }
}
