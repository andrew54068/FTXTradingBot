//
//  DecodableWrapper.swift
//  
//
//  Created by Andrew Wang on 2021/8/30.
//

import Foundation

struct DecodableWrapper<T: Decodable>: Decodable {
    let value: T
}
