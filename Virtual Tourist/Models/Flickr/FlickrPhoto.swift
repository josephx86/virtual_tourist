//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/26/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

struct FlickrPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int32
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}
