//
//  startService.swift
//  
//
//  Created by Andrew Wang on 2021/8/31.
//

import Vapor

public func startService(app: Application) {
    let apiSecret: String = Environment.get("apiSecret") ?? ""
    let apiKey: String = Environment.get("apiKey") ?? ""
    let subAccount: String = Environment.get("subAccount") ?? ""
    assert(apiSecret.isEmpty == false, "apiSecret not found in .env.*")
    assert(apiKey.isEmpty == false, "apiKey not found in .env.*")
    assert(subAccount.isEmpty == false, "subAccount not found in .env.*")

    let ftx = FTXClient(
        apiKey: apiKey,
        apiSecret: apiSecret,
        subAccountName: subAccount,
        client: app.client)
    ftx.placeOrder(tradingTargetType: .perpetual(crypto: .bitcoin))
}
