//
//  FTXSingleMarketRequest.swift
//
//
//  Created by Andrew Wang on 2021/9/4.
//

import NIOHTTP1

struct FTXSingleMarketRequest: FTXTargetType {
    typealias ResultType = MarketModel

    var method: HTTPMethod {
        .GET
    }

    var keyPath: String? {
        "result"
    }

    var path: String {
        "/api/markets/\(name)"
    }

    var task: Task {
        .requestPlain
    }

    let name: String

    var needSignature: Bool {
        false
    }
}
