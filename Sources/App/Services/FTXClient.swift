//
//  FTXClient.swift
//  
//
//  Created by Andrew Wang on 2021/8/29.
//

import Foundation
import CryptoKit
import Moya
import RxSwift
import Vapor

class FTXClient {
    let apiSecret: String
    let apiKey: String
    let subAccountName: String?
    let client: Vapor.Client
    
    private lazy var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var apiProvider: FTXProvider = FTXProvider(
        apiKey: apiKey,
        apiSecret: apiSecret,
        subAccountName: subAccountName)
    
    private lazy var plugin = FTXRequestHeaderPlugin(
        apiKey: apiKey,
        apiSecret: apiSecret,
        subAccountName: subAccountName)
    
    private let jsonDecoder = JSONDecoder()
    
    init(apiKey: String,
         apiSecret: String,
         subAccountName: String? = nil,
         client: Vapor.Client) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.subAccountName = subAccountName
        self.client = client
    }
    
    func fetchAccount() {
        let accountRequest = FTXAccountRequest()
        get(request: accountRequest)
            .subscribe(onSuccess: { account in
                print(account)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func placeOrder(tradingTargetType: TradingTargetType) {
        let orderRequest = FTXPlaceOrderRequest(
            marketSymbol: tradingTargetType.marketSymbol(.ftx),
            price: 7500,
            orderActionType: .limit(.buy),
            tradeVolume: 1,
            reduceOnly: false)
        post(request: orderRequest)
            .subscribe(onSuccess: { orderResponseModel in
                print(orderResponseModel)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func get<Request: FTXTargetType>(request: Request) -> Single<Request.ResultType> {
        fetch(request: request, method: .get)
    }
    
    func post<Request: FTXTargetType>(request: Request) -> Single<Request.ResultType> {
        fetch(request: request, method: .post)
    }
    
    private func fetch<Request: FTXTargetType>(request: Request, method: Moya.Method) -> Single<Request.ResultType> {
        let endpoint = MoyaProvider.defaultEndpointMapping(for: request)
        return Single<Request.ResultType>.create { [weak self] single in
            do {
                guard let self = self else {
                    throw ResponseError.handlerNotFound
                }
                let urlRequest: URLRequest = try endpoint.urlRequest()
                let adjustedRequest: URLRequest = self.plugin.prepare(urlRequest, method: method, target: request)
                let headerFields = adjustedRequest.allHTTPHeaderFields?.map {
                    ($0, $1)
                } ?? []
                let headers: HTTPHeaders = HTTPHeaders(headerFields)
                let future: EventLoopFuture<ClientResponse>
                switch method {
                case .get:
                    future = self.client.get(
                        URI(string: endpoint.url),
                        headers: headers)
                case .post:
                    let bodyBufferAllocator = ByteBufferAllocator()
                    let bodyBuffer = bodyBufferAllocator.buffer(data: adjustedRequest.httpBody ?? Data())
                    
                    let request = ClientRequest(
                        method: .POST,
                        url: URI(string: endpoint.url),
                        headers: headers,
                        body: bodyBuffer)
                    future = self.client.send(request)
                default:
                    throw ResponseError.methodUnsupported
                }
                let response: ClientResponse = try future.wait()
                if var body: ByteBuffer = response.body,
                   let bodyData = body.readData(length: body.readableBytes) {
                    let resultModel: Request.ResultType = try response.map(
                        Request.ResultType.self,
                        data: bodyData,
                        atKeyPath: request.keyPath,
                        using: self.jsonDecoder)
                    single(.success(resultModel))
                } else {
                    single(.error(ResponseError.responseDataNotFound))
                }
            } catch {
                single(.error(error))
            }
            return Disposables.create { }
        }
    }
}

enum Exchange {
    case ftx
}

enum Crypto {
    case bitcoin
    case ethereum
    case solana
    case cardano
    case usdt
    case usd
    
    var symbol: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .ethereum:
            return "ETH"
        case .solana:
            return "SOL"
        case .cardano:
            return "ADA"
        case .usdt:
            return "USDT"
        case .usd:
            return "USD"
        }
    }
}

enum TradingTargetType {
    case spot(pair: Pair)
    case perpetual(crypto: Crypto)
    
    func marketSymbol(_ exchange: Exchange) -> String {
        switch exchange {
        case .ftx:
            switch self {
            case .spot(let pair):
                return "\(pair.base)/\(pair.quote)"
            case .perpetual(let crypto):
                return "\(crypto.symbol)-PERP"
            }
        }
    }
}

struct Pair {
    let base: Crypto
    let quote: Crypto
}
