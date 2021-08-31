//
//  FTXTargetType.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation
import Moya

protocol FTXTargetType: TargetType, FTXSignatureTargetType {
    
    associatedtype ResultType: Decodable
    
    var keyPath: String? { get }
}

extension FTXTargetType {
    
    var baseURL: URL {
        URL(string: "https://ftx.com")!
    }
    
    var sampleData: Data { Data() }
    
    var currentTimestamp: TimeInterval {
        Date().timeIntervalSince1970
    }
    
    var headers: [String: String]? { [:] }

}
