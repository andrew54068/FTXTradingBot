//
//  FTXSignatureTargetType.swift
//
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation
import NIOHTTP1

protocol FTXSignatureTargetType {
    var method: HTTPMethod { get }

    var path: String { get }

    var needSignature: Bool { get }
}

extension FTXSignatureTargetType {
    var needSignature: Bool {
        true
    }
}
