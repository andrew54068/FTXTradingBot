//
//  FTXAccountRequest.swift
//
//
//  Created by Andrew Wang on 2021/8/30.
//

import NIOHTTP1

struct FTXAccountRequest: FTXTargetType, FTXSignatureTargetType {
    typealias ResultType = Account

    var method: HTTPMethod {
        .GET
    }

    var keyPath: String? {
        "result"
    }

    var path: String {
        "/api/account"
    }

    var task: Task {
        .requestPlain
    }
}
