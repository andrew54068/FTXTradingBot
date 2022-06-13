//
//  MarketModel.swift
//
//
//  Created by Andrew Wang on 2022/1/4.
//

import Foundation

struct MarketModel: Decodable {
    let ask: Double
    let bid: Double
    let last: Double
}
