//
//  ResponseError.swift
//
//
//  Created by Andrew Wang on 2021/8/30.
//

import Vapor

enum ResponseError: Error {
    case methodUnsupported
    case handlerNotFound
    case responseDataNotFound
    case jsonMapping(ClientResponse)
    case objectMapping(Error, ClientResponse)
}
