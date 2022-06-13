//
//  FTXPlaceOrderRequest.swift
//
//
//  Created by Andrew Wang on 2021/8/31.
//

import Foundation
import NIOHTTP1
import Vapor

struct FTXPlaceOrderRequest: FTXTargetType, FTXSignatureTargetType {
    typealias ResultType = OrderResponseModel

    var method: HTTPMethod {
        .POST
    }

    var keyPath: String? {
        "result"
    }

    var path: String {
        "/api/orders"
    }

    var task: Task {
        var param: [String: Any] = [
            "market": marketSymbol,
            "side": orderActionType.action,
            "type": orderActionType.type.rawValue,
            "size": baseVolume,
            "reduceOnly": false,
            "ioc": false,
            "postOnly": false,
        ]
        if case let .limit(_, price) = orderActionType {
            param["price"] = price
        } else {
            param.updateValue(NSNull(), forKey: "price")
        }
        return .requestParameters(parameters: param, encoding: JSONEncoding(options: .withoutEscapingSlashes))
    }

    let marketSymbol: String
    let orderActionType: OrderActionType
    let baseVolume: Double
    let reduceOnly: Bool
}

enum TradeVolume {
    case base(Double)
    case quote(Double)
}

enum OrderActionType {
    case limit(tradeAction: TradeAction, price: Double)
    case market(tradeAction: TradeAction)

    var type: OrderType {
        switch self {
        case .limit:
            return .limit
        case .market:
            return .market
        }
    }

    var actionType: TradeAction {
        switch self {
        case let .limit(tradeAction, _),
             let .market(tradeAction):
            return tradeAction
        }
    }

    var action: String {
        switch self {
        case let .limit(tradeAction, _):
            return tradeAction.rawValue
        case let .market(tradeAction):
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

public struct OrderResponseModel: Decodable {
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

// extension OrderResponseModel: ResponseEncodable {
//
//    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
//        <#code#>
//    }
//
// }

enum FTXOrderStatus {
    case open
}
