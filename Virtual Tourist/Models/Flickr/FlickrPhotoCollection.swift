//
//  FlickrPhotoCollection.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/26/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

struct FlickrPhotoCollection: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photos: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photos = "photo"
    }
}
