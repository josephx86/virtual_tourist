//
//  HttpHelper.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/26/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation

typealias FlickrErrorDelegate = (String) -> Void
typealias FlickrSearchResultsDelegate = (FlickrSearchResults) -> Void
typealias FlickrImageDownloadDelegate = (Photo, Data, PhotoCellView) -> Void

class HttpHelper {
    
    class fileprivate func handleSearchResults(data: Data, _ onSuccess: @escaping FlickrSearchResultsDelegate, _ onError: @escaping FlickrErrorDelegate) {
        let decoder = JSONDecoder()
        if let searchResults: FlickrSearchResults = try? decoder.decode(FlickrSearchResults.self, from: data) {
            DispatchQueue.main.async {
                onSuccess(searchResults)
            }
        } else if let flickrError: FlickrError = try? decoder.decode(FlickrError.self, from: data) {
            DispatchQueue.main.async {
                onError(flickrError.message)
            }
        } 
    }
    
    class func searchPhotos(latitude: Double, longitude: Double, page: Int, onSuccess: @escaping FlickrSearchResultsDelegate, onError: @escaping FlickrErrorDelegate) {
        let apiKey = "903c68ed7fdf1e8a61e327f8415769ce"
        let endPoint = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&page=\(page)&format=json"
        if let url = URL(string: endPoint) {
            let task = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
                if let resultData = data {
                    // Remove bytes for leading 'jsonFlickrApi(' and also trailing ')'
                    // so that we have clean json
                    let range = Range(14...resultData.count - 2)
                    let jsonData = resultData.subdata(in: range)
                    handleSearchResults(data: jsonData, onSuccess, onError)
                }
            }
            task.resume()
        }
    }
    
    class func downloadPhoto(photo: Photo, cell: PhotoCellView, onSuccess: @escaping FlickrImageDownloadDelegate) {
        let address = "https://farm\(photo.farm).staticflickr.com/\(photo.server!)/\(photo.id!)_\(photo.secret!)_q.jpg"
        if let url = URL(string: address) {
            let task = URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
                if let resultData = data {
                    DispatchQueue.main.async {
                        onSuccess(photo, resultData, cell)
                    }
                }
            }
            task.resume()
        }
    }
}
