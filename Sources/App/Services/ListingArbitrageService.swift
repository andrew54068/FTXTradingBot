//
//  ListingArbitrageService.swift
//  
//
//  Created by Andrew Wang on 2021/9/19.
//

import Foundation
import RxSwift
import Vapor

final class ListingArbitrageService {
    
    let ftx: FTXClient
    let logger: Logger
    
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
    init(ftxClient: FTXClient,
         logger: Logger) {
        self.ftx = ftxClient
        self.logger = logger
    }
    
    func start(bidPrice: Double, tradingTargetType: TradingTargetType) {
        ftx
            .fetchAccount()
            .flatMap { [weak self] account -> Single<OrderResponseModel> in
                guard let self = self else { return Single.error(ServiceError.internal) }
                switch tradingTargetType {
                case .spot(let pair):
                    return self.addSpotOrder(
                        pair: pair,
                        price: bidPrice,
                        tradeVolume: account.totalAccountValue)
                case .perpetual(let crypto):
                    return self.addFutureOrder(
                        crypto: crypto,
                        price: bidPrice,
                        tradeVolume: account.totalAccountValue)
                }
            }
            .retry(20)
            .subscribe(onSuccess: { [weak self] orderResponseModel in
                self?.logger.info("\(orderResponseModel)")
            }, onError: { [weak self] error in
                self?.logger.error("\(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func addSpotOrder(
        pair: Pair,
        price: Double,
        tradeVolume: Double) -> Single<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .spot(pair: pair),
                orderActionType: .limit(tradeAction: .buy, price: price),
                tradeVolume: .base(tradeVolume))
    }
    
    private func addFutureOrder(
        crypto: Crypto,
        price: Double,
        tradeVolume: Double) -> Single<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .perpetual(crypto: crypto),
                orderActionType: .limit(tradeAction: .buy, price: price),
                tradeVolume: .base(tradeVolume))
    }
}
