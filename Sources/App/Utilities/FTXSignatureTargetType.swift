//
//  FTXSignatureTargetType.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation
import Moya

protocol FTXSignatureTargetType {
    var method: Moya.Method { get }
    var path: String { get }
    var currentTimestamp: TimeInterval { get }
}
