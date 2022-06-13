//
//  ListingArbitrageService.swift
//
//
//  Created by Andrew Wang on 2021/9/19.
//

import Vapor

/// Arbitrage when specific coin is listing.
final class ListingArbitrageService {
    let ftx: FTXClient
    let logger: Logger

    init(
        ftxClient: FTXClient,
        logger: Logger
    ) {
        ftx = ftxClient
        self.logger = logger
    }

    func start(
        bidPrice: Double,
        tradingTargetType: TradingTargetType
    ) -> EventLoopFuture<OrderResponseModel> {
        let eventLoop = ftx.client.eventLoop
        return ftx
            .fetchAccount()
            .flatMap { [weak self] account -> EventLoopFuture<OrderResponseModel> in
                guard let self = self else {
                    return eventLoop.makeFailedFuture(Error.internal)
                }
                switch tradingTargetType {
                case let .spot(pair):
                    return self.addSpotOrder(
                        pair: pair,
                        price: bidPrice,
                        tradeVolume: account.totalAccountValue
                    )
                case let .perpetual(crypto):
                    return self.addFutureOrder(
                        crypto: crypto,
                        price: bidPrice,
                        tradeVolume: account.totalAccountValue
                    )
                }
            }
//            .subscribe(onSuccess: { [weak self] orderResponseModel in
//                self?.logger.info("\(orderResponseModel)")
//            }, onError: { [weak self] error in
//                self?.logger.error("\(error)")
//            })
//            .disposed(by: disposeBag)
    }

    private func addSpotOrder(
        pair: Pair,
        price: Double,
        tradeVolume: Double
    ) -> EventLoopFuture<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .spot(pair: pair),
                orderActionType: .limit(tradeAction: .buy, price: price),
                tradeVolume: .quote(tradeVolume)
            )
    }

    private func addFutureOrder(
        crypto: Crypto,
        price: Double,
        tradeVolume: Double
    ) -> EventLoopFuture<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .perpetual(crypto: crypto),
                orderActionType: .limit(tradeAction: .buy, price: price),
                tradeVolume: .base(tradeVolume)
            )
    }
}

extension ListingArbitrageService {
    enum Error: Swift.Error {
        case `internal`
    }
}
