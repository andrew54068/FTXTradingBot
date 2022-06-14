//
//  Endpoint.swift
//
//
//  Created by Andrew Wang on 2022/1/4.
//

import Foundation
import NIOHTTP1

final class Endpoint {
    /// A string representation of the URL for the request.
    var urlString: String

    /// The HTTP method for the request.
    let method: HTTPMethod

    /// The path to be appended to `baseURL` to form the full `URL`.
    let path: String

    /// The `Task` for the request.
    let task: Task

    /// The HTTP header fields for the request.
    var httpHeaderFields: [String: String]?

    var headerForRequest: HTTPHeaders {
        let headerFields = httpHeaderFields?.map {
            ($0, $1)
        } ?? []
        return HTTPHeaders(headerFields)
    }

    var httpBody = Data()

    init(
        urlString: String,
        method: HTTPMethod,
        path: String,
        task: Task,
        httpHeaderFields: [String: String]?
    ) {
        self.urlString = urlString
        self.method = method
        self.path = path
        self.task = task
        self.httpHeaderFields = httpHeaderFields
        assignData(from: task)
    }

    func adding(newHTTPHeaderFields: [String: String]) -> Endpoint {
        return Endpoint(
            urlString: urlString,
            method: method,
            path: path,
            task: task,
            httpHeaderFields: add(
                httpHeader: newHTTPHeaderFields)
        )
    }

    func addingValue(_ value: String, newHTTPHeaderFields: String) -> Endpoint {
        return Endpoint(
            urlString: urlString,
            method: method,
            path: path,
            task: task,
            httpHeaderFields: addValue(
                value,
                forHTTPHeaderField: newHTTPHeaderFields
            )
        )
    }

    private func assignData(from task: Task) {
        switch task {
        case .requestPlain:
            return
        case let .requestData(data):
            httpBody = data
        case let .requestJSONEncodable(encodable):
            do {
                let encodable = AnyEncodable(encodable)
                httpBody = try JSONEncoder().encode(encodable)
            } catch {
                assertionFailure("shouldn't be the case.")
            }
        case let .requestParameters(parameters, parameterEncoding):
            do {
                try parameterEncoding.encode(self, with: parameters)
            } catch {
                assertionFailure("shouldn't be the case.")
            }
        }
    }

    private func add(httpHeader headers: [String: String]?) -> [String: String]? {
        guard let unwrappedHeaders = headers,
              unwrappedHeaders.isEmpty == false else {
            return httpHeaderFields
        }

        var newHTTPHeaderFields = httpHeaderFields ?? [:]
        unwrappedHeaders.forEach { key, value in
            newHTTPHeaderFields[key] = value
        }
        return newHTTPHeaderFields
    }

    private func addValue(_ value: String, forHTTPHeaderField: String) -> [String: String]? {
        var newHTTPHeaderFields = httpHeaderFields ?? [:]
        newHTTPHeaderFields[forHTTPHeaderField] = value
        return newHTTPHeaderFields
    }
}
