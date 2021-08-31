//
//  Account.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation

struct Account: Decodable {
    let makerFee: Double
    let takerFee: Double
    let username: String
}
