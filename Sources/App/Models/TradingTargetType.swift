//
//  TradingTargetType.swift
//
//
//  Created by Andrew Wang on 2022/1/4.
//

import Foundation

enum TradingTargetType {
    case spot(pair: Pair)
    case perpetual(crypto: Crypto)

    func marketSymbol(_ exchange: Exchange) -> String {
        switch exchange {
        case .ftx:
            switch self {
            case let .spot(pair):
                return "\(pair.base.symbol)/\(pair.quote.symbol)"
            case let .perpetual(crypto):
                return "\(crypto.symbol)-PERP"
            }
        }
    }
}
