//
//  FundingFeeArbitrageService.swift
//  
//
//  Created by Andrew Wang on 2021/9/6.
//

import Foundation
import RxSwift
import Vapor

final class FundingFeeArbitrageService {
    let ftx: FTXClient
    let logger: Logger
    
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
    init(ftxClient: FTXClient,
         logger: Logger) {
        self.ftx = ftxClient
        self.logger = logger
    }
    
    func setup(crypto: Crypto, leverage: Double) {
        ftx
            .fetchAccount()
            .flatMap { [weak self] account -> Single<(OrderResponseModel, OrderResponseModel)> in
                guard let self = self else { return Single.error(ServiceError.internal) }
                let spotInvestment = account.totalAccountValue * leverage / (leverage + 1)
                let futureInvestment = account.totalAccountValue * leverage / (leverage + 1)
                let pair = Pair(base: crypto, quote: Crypto.usd)
                return Single.zip(
                    self.addSpotOrder(pair: pair, tradeVolume: spotInvestment),
                    self.addFutureOrder(crypto: crypto, tradeVolume: futureInvestment))
            }
            .subscribe(onSuccess: { [weak self] stopOrderResponse, futureOrderResponse in
                self?.logger.info("\(stopOrderResponse)")
                self?.logger.info("\(futureOrderResponse)")
            }, onError: { [weak self] error in
                self?.logger.error("\(error)")
            })
            .disposed(by: disposeBag)
    }
    
    private func addSpotOrder(pair: Pair, tradeVolume: Double) -> Single<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .spot(pair: pair),
                orderActionType: .market(tradeAction: .buy),
                tradeVolume: .base(tradeVolume))
    }
    
    private func addFutureOrder(crypto: Crypto, tradeVolume: Double) -> Single<OrderResponseModel> {
        ftx
            .placeOrder(
                tradingTargetType: .perpetual(crypto: crypto),
                orderActionType: .market(tradeAction: .sell),
                tradeVolume: .base(tradeVolume))
    }
}
