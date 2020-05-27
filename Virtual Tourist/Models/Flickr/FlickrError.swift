//
//  FlickrError.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/26/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

struct FlickrError: Codable {
    let code: Int
    let status: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case status = "stat"
        case message
    } 
}
