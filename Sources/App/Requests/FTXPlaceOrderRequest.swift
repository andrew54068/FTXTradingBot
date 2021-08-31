//
//  FTXPlaceOrderRequest.swift
//  
//
//  Created by Andrew Wang on 2021/8/31.
//

import Moya
import Foundation

struct FTXPlaceOrderRequest: FTXTargetType {
    
    typealias ResultType = OrderResponseModel
    
    var method: Moya.Method {
        .post
    }
    
    var keyPath: String? {
        "result"
    }
    
    var path: String {
        "/api/orders"
    }
    
    var task: Task {
        let param: Dictionary<String, Any> = [
            "market": marketSymbol,
            "side": orderActionType.action,
            "price": price,
            "type":  orderActionType.type.rawValue,
            "size": tradeVolume,
            "reduceOnly": false,
            "ioc": false,
            "postOnly": false,
        ]
        return .requestParameters(parameters: param, encoding: JSONEncoding(options: .withoutEscapingSlashes))
    }
    
    let marketSymbol: String
    let price: Double
    let orderActionType: OrderActionType
    let tradeVolume: Double
//    let tradeVolume: TradeVolume
    let reduceOnly: Bool
    
}

enum TradeVolume {
    case base(Decimal)
    case quote(Decimal)
}

enum OrderActionType {
    case limit(TradeAction)
    case market(TradeAction)
    
    var type: OrderType {
        switch self {
        case .limit:
            return .limit
        case .market:
            return .market
        }
    }
    
    var action: String {
        switch self {
        case .limit(let tradeAction):
            return tradeAction.rawValue
        case .market(let tradeAction):
            return tradeAction.rawValue
        }
    }
}

enum OrderType: String {
    case limit
    case market
}

enum TradeAction: String {
    case buy
    case sell
}

struct OrderResponseModel: Decodable {
    let id: Int
    let createdAt: String
    let filledSize: Double
    let future: String
    let market: String
    let side: String
    let price: Double
    let size: Double
    let remainingSize: Double
    let status: String
//    let status: FTXOrderStatus
    let type: String
//    let type: OrderType
    let reduceOnly: Bool
    let ioc: Bool
    let postOnly: Bool
    let clientId: String?
}

enum FTXOrderStatus {
    case open
}
