//
//  FTXTargetType.swift
//
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation
import NIOHTTP1

struct AnyEncodable: Encodable {
    private let encodable: Encodable

    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}

enum Task {
    /// A request with no additional data.
    case requestPlain

    /// A requests body set with data.
    case requestData(Data)

    /// A request body set with `Encodable` type
    case requestJSONEncodable(Encodable)

    /// A requests body set with encoded parameters.
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
}

protocol TargetType {
    /// The target's base `URL`.
    var baseURL: URL { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: HTTPMethod { get }

    /// Provides stub data for use in testing.
    var sampleData: Data { get }

    /// The type of HTTP task to be performed.
    var task: Task { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }
}

extension TargetType {
    var urlString: String {
        let targetPath = path
        if targetPath.isEmpty {
            return baseURL.absoluteString
        } else {
            return baseURL.appendingPathComponent(targetPath).absoluteString
        }
    }
}

protocol FTXTargetType: TargetType {
    associatedtype ResultType: Decodable

    var keyPath: String? { get }

    var urlString: String { get }

    var needSignature: Bool { get }
}

extension FTXTargetType {
    var baseURL: URL {
        URL(string: "https://ftx.com")!
    }

    var sampleData: Data { Data() }

    var headers: [String: String]? { [:] }
}
