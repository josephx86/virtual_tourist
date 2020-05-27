//
//  FlickrSearchResults.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/26/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

struct FlickrSearchResults: Codable {
    let stat: String
    let photoCollection: FlickrPhotoCollection
    
    enum CodingKeys: String, CodingKey {
        case stat
        case photoCollection = "photos"
    }
}
