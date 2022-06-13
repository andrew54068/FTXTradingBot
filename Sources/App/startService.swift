//
//  startService.swift
//
//
//  Created by Andrew Wang on 2021/8/31.
//

import Jobs
import Vapor

let maxAttemptCount = 3

var globalListingArbitrageService: ListingArbitrageService?

public func startService(app: Application) -> EventLoopFuture<OrderResponseModel> {
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
        client: app.client,
        logger: app.logger
    )

    let listingArbitrageService = ListingArbitrageService(
        ftxClient: ftx,
        logger: app.logger
    )
    
    globalListingArbitrageService = listingArbitrageService

    return listingArbitrageService.start(
        bidPrice: 0.05,
        tradingTargetType: .spot(
            pair: Pair(
                base: Crypto.bloctoToken,
                quote: Crypto.usd
            ))
    )

    /*
     grid trade
     */
    /*
      let fundingFeeArbitrageService = FundingFeeArbitrageService(
          ftxClient: ftx,
          logger: app.logger)
     fundingFeeArbitrageService.setup(crypto: .mango, leverage: 2.0)
      */

    /*
     grid trade
     */
    /*
     let gridTradingService = GridTradingService(
         ftxClient: ftx,
         logger: app.logger)
     gridTradingService.start(pair: <#T##Pair#>, totalGrid: <#T##UInt#>)
     */
}

enum ServiceError: Error {
    case `internal`
}
