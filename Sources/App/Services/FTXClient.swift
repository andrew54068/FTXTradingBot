//
//  FTXClient.swift
//
//
//  Created by Andrew Wang on 2021/8/29.
//

import AsyncHTTPClient
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    import CryptoKit
#else
    import Crypto
#endif
import Foundation
import Vapor

class FTXClient {
    let apiSecret: String
    let apiKey: String
    let subAccountName: String?
    let client: Vapor.Client
    let logger: Logger

    private lazy var plugin = FTXRequestHeaderPlugin(
        apiKey: apiKey,
        apiSecret: apiSecret,
        subAccountName: subAccountName
    )

    private let jsonDecoder = JSONDecoder()

    init(
        apiKey: String,
        apiSecret: String,
        subAccountName: String? = nil,
        client: Vapor.Client,
        logger: Logger
    ) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.subAccountName = subAccountName
        self.client = client
        self.logger = logger
    }

    func fetchAccount() -> EventLoopFuture<Account> {
        let accountRequest = FTXAccountRequest()
        return get(request: accountRequest)
    }

    func placeOrder(
        tradingTargetType: TradingTargetType,
        orderActionType: OrderActionType,
        tradeVolume: TradeVolume,
        reduceOnly: Bool = false
    ) -> EventLoopFuture<OrderResponseModel> {
        let eventLoop = client.eventLoop
        switch tradeVolume {
        case let .base(volume):
            let orderRequest = FTXPlaceOrderRequest(
                marketSymbol: tradingTargetType.marketSymbol(.ftx),
                orderActionType: orderActionType,
                baseVolume: volume,
                reduceOnly: reduceOnly
            )
            return post(request: orderRequest)
        case let .quote(volume):
            return getSingleMarket(tradingTargetType: tradingTargetType)
                .flatMap { [weak self] marketModel in
                    guard let self = self else {
                        return eventLoop.makeFailedFuture(FTXClientError.internal)
                    }
                    let baseVolume: Double
                    switch orderActionType.actionType {
                    case .buy:
                        let sellPrice = marketModel.ask
                        baseVolume = floor(volume / sellPrice)
                    case .sell:
                        let buyPrice = marketModel.bid
                        baseVolume = floor(volume / buyPrice)
                    }
                    let orderRequest = FTXPlaceOrderRequest(
                        marketSymbol: tradingTargetType.marketSymbol(.ftx),
                        orderActionType: orderActionType,
                        baseVolume: baseVolume,
                        reduceOnly: reduceOnly
                    )
                    return self.post(request: orderRequest)
                }
        }
    }

    func getSingleMarket(tradingTargetType: TradingTargetType) -> EventLoopFuture<MarketModel> {
        let request = FTXSingleMarketRequest(name: tradingTargetType.marketSymbol(.ftx))
        return get(request: request)
    }

    func get<Request: FTXTargetType>(request: Request) -> EventLoopFuture<Request.ResultType> {
        fetch(request: request)
    }

    func post<Request: FTXTargetType>(request: Request) -> EventLoopFuture<Request.ResultType> {
        fetch(request: request)
    }

    private func fetch<Request: FTXTargetType>(request: Request) -> EventLoopFuture<Request.ResultType> {
        var endpoint = Endpoint(
            urlString: request.urlString,
            method: request.method,
            path: request.path,
            task: request.task,
            httpHeaderFields: request.headers
        )
        if request.needSignature {
            endpoint = plugin.prepare(endpoint: endpoint)
        }

        let future: EventLoopFuture<ClientResponse>
        switch endpoint.method {
        case .GET:
            future = client.get(
                URI(string: endpoint.urlString),
                headers: endpoint.headerForRequest
            )
        case .POST:
            let bodyBufferAllocator = ByteBufferAllocator()
            let bodyBuffer = bodyBufferAllocator.buffer(data: endpoint.httpBody)

            let request = ClientRequest(
                method: endpoint.method,
                url: URI(string: endpoint.urlString),
                headers: endpoint.headerForRequest,
                body: bodyBuffer
            )
            future = client.send(request)
        default:
            let promise = client.eventLoop.makePromise(of: Request.ResultType.self)
            promise.fail(FTXClientError.badRequest)
            return promise.futureResult
        }
        return future
            .flatMapThrowing { response in
                if var body: ByteBuffer = response.body,
                   let bodyData = body.readData(length: body.readableBytes) {
                    let resultModel: Request.ResultType = try response.map(
                        data: bodyData,
                        atKeyPath: request.keyPath,
                        using: self.jsonDecoder
                    )
                    return resultModel
                } else {
                    throw ResponseError.responseDataNotFound
                }
            }
//            .whenComplete { result in
//                switch result {
//                case .success:
//                    self.logger.log(level: .info, "order success.")
//                case .failure(let error):
//                    self.logger.log(level: .info, "\(error.localizedDescription)")
//                }
//            }
    }
}

enum FTXClientError: Error {
    case `internal`
    case badRequest
}
