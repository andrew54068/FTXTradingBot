//
//  FTXSingleMarketRequest.swift
//  
//
//  Created by Andrew Wang on 2021/9/4.
//

import Moya

struct FTXSingleMarketRequest: FTXTargetType {
    typealias ResultType = MarketModel
    
    var method: Moya.Method {
        .get
    }
    
    var keyPath: String? {
        "result"
    }
    
    var path: String {
        "/api/markets/\(name)}"
    }
    
    var task: Task {
        .requestPlain
    }
    
    let name: String
    
}

struct MarketModel: Decodable {
    let ask: Double
    let bid: Double
    let last: Double
}
