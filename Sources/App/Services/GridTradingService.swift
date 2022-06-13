//
//  GridTradingService.swift
//
//
//  Created by Andrew Wang on 2021/9/6.
//

import Foundation
import Jobs
import Vapor

struct GridTradingBoundary {
    let upper: Double
    let lower: Double
}

final class GridTradingService {
    let ftx: FTXClient
    let logger: Logger

//    private lazy var disposeBag: DisposeBag = DisposeBag()

    init(
        ftxClient: FTXClient,
        logger: Logger
    ) {
        ftx = ftxClient
        self.logger = logger
    }

    func start(
        pair: Pair,
        totalGrid: UInt,
        boundary: GridTradingBoundary
    ) {
        do {
            let account = try ftx.fetchAccount().wait()
            Jobs.add(interval: .seconds(5)) { [weak self] in
                self?.gridTrading(
                    account: account,
                    pair: pair,
                    totalGrid: totalGrid,
                    boundary: boundary
                )
            }
        } catch {
            logger.error("\(error)")
        }
    }

    func gridTrading(
        account _: Account,
        pair _: Pair,
        totalGrid _: UInt,
        boundary _: GridTradingBoundary
    ) {
        // check account balance match with grid settings
//        do {
        let eventLoop: EventLoop = ftx.client.eventLoop
//        _ = ftx.getSingleMarket(tradingTargetType: .spot(pair: pair))
//            .flatMap { [unowned self] marketModel -> EventLoopFuture<[Result<OrderResponseModel, Error>]> in
        ////                guard let self = self else { return eventLoop.makeFailedFuture(Error.internal) }
//                let getCurrentPrice = marketModel.last
//                let orders: [EventLoopFuture<OrderResponseModel>] = self.setGridOrders(
//                    pair: pair,
//                    currentPrice: getCurrentPrice,
//                    totalGrid: totalGrid)
//                return EventLoopFuture<OrderResponseModel>.whenAllComplete(
//                    orders,
//                    on: eventLoop)
//            }
//            .whenComplete({ [weak self] result in
//                switch result {
//                case let .success(orderResponseModels):
//                    self?.logger.info("\(orderResponseModels)")
//                    //                    self?.logger.info("\(futureOrderResponse)")
//                case .failure(let error):
//                    self?.logger.error("\(error)")
//                }
//            })
    }

//    private func generateGridOrder() -> [] {
//
//    }

    private func setGridOrders(
        pair _: Pair,
        currentPrice _: Double,
        totalGrid _: UInt
    ) -> [EventLoopFuture<OrderResponseModel>] {
        return []
    }

    private func setSingleOrder(
        tradeAction: TradeAction,
        pair: Pair,
        price: Double,
        tradeVolume: TradeVolume
    ) -> EventLoopFuture<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .spot(pair: pair),
                orderActionType: .limit(tradeAction: tradeAction, price: price),
                tradeVolume: tradeVolume
            )
//            .map { Optional($0) }
//            .retry(maxAttemptCount)
//            .catchErrorJustReturn(nil)
    }
}

extension GridTradingService {
    enum Error: Swift.Error {
        case `internal`
    }
}
