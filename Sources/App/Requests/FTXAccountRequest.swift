//
//  FTXAccountRequest.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Moya

struct FTXAccountRequest: FTXTargetType {
    
    typealias ResultType = Account
    
    var method: Moya.Method {
        .get
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
