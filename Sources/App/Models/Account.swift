//
//  Account.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation

struct Account: Decodable {
    let username: String
    let makerFee: Double
    let takerFee: Double
    
    let collateral: Double
    let freeCollateral: Double
    let totalAccountValue: Double
    
    let marginFraction: Double?
    let openMarginFraction: Double?
    let initialMarginRequirement: Double
    let maintenanceMarginRequirement: Double
}
