//
//  FundingFeeArbitrageService.swift
//
//
//  Created by Andrew Wang on 2021/9/6.
//

import Foundation
import Vapor

final class FundingFeeArbitrageService {
    let ftx: FTXClient
    let logger: Logger

    init(
        ftxClient: FTXClient,
        logger: Logger
    ) {
        ftx = ftxClient
        self.logger = logger
    }

    func setup(crypto: Crypto, leverage: Double) {
        let eventLoop = ftx.client.eventLoop
        ftx
            .fetchAccount()
            .flatMap { [weak self] account -> EventLoopFuture<[Result<OrderResponseModel, Error>]> in
                guard let self = self else {
                    return eventLoop.makeFailedFuture(ServiceError.internal)
                }
                let spotInvestment = account.totalAccountValue * leverage / (leverage + 1)
                let futureInvestment = account.totalAccountValue * leverage / (leverage + 1)
                let pair = Pair(base: crypto, quote: Crypto.usd)
                return EventLoopFuture
                    .whenAllComplete(
                        [
                            self.addSpotOrder(pair: pair, tradeVolume: spotInvestment),
                            self.addFutureOrder(crypto: crypto, tradeVolume: futureInvestment),
                        ],
                        on: self.ftx.client.eventLoop
                    )
            }
            .whenComplete { [weak self] result in
                switch result {
                case let .success(orderResponses):
                    self?.logger.info("\(orderResponses)")
                case let .failure(error):
                    self?.logger.error("\(error)")
                }
            }
    }

    private func addSpotOrder(pair: Pair, tradeVolume: Double) -> EventLoopFuture<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .spot(pair: pair),
                orderActionType: .market(tradeAction: .buy),
                tradeVolume: .base(tradeVolume)
            )
    }

    private func addFutureOrder(crypto: Crypto, tradeVolume: Double) -> EventLoopFuture<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .perpetual(crypto: crypto),
                orderActionType: .market(tradeAction: .sell),
                tradeVolume: .base(tradeVolume)
            )
    }
}
