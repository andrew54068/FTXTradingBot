//
//  Crypto.swift
//
//
//  Created by Andrew Wang on 2022/1/4.
//

import Foundation

enum Crypto {
    case bitcoin
    case ethereum
    case solana
    case cardano
    case mango
    case bloctoToken
    case usdt
    case usd

    var symbol: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .ethereum:
            return "ETH"
        case .solana:
            return "SOL"
        case .cardano:
            return "ADA"
        case .mango:
            return "MNGO"
        case .bloctoToken:
            return "BLT"
        case .usdt:
            return "USDT"
        case .usd:
            return "USD"
        }
    }
}
