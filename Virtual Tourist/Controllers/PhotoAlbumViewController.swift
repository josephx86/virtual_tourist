//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/26/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    var cameraAltitude: Double! 
    var placePhotos: [Photo] = []
    var albumPlace: Pin!
    let cellReuseId = "photoCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        mapView.delegate = self
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        showAnnotation()
        getSavedPhotos()
    }
    
    func updateUI(state: CollectionState) {
        switch state {
        case .empty:
            activityIndicator.stopAnimating()
            newCollectionButton.isHidden = true
            photosCollectionView.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "No photos found for this place ☹️"
        case .searching:
            activityIndicator.startAnimating()
            newCollectionButton.isHidden = true
            photosCollectionView.isHidden = true
            statusLabel.isHidden = false
            statusLabel.text = "Getting photos for this place..."
        default:
            activityIndicator.stopAnimating()
            newCollectionButton.isHidden = false
            photosCollectionView.isHidden = false
            statusLabel.isHidden = true
            statusLabel.text = ""
            photosCollectionView.reloadData()
        }
    }
    
    func searchPhotosOnline(page: Int = 1) {
        updateUI(state: .searching)
        HttpHelper.searchPhotos(latitude: albumPlace.latitude, longitude: albumPlace.longitude, page: page, onSuccess: loadDownloadedPhotos, onError: showMessage)
    }
    
    @IBAction func newCollection(_ sender: Any) {
        updateUI(state: .searching)
        
        // Delete any saved photos
        while (placePhotos.count > 0) {
            let photo = placePhotos.remove(at: 0)
            albumPlace.managedObjectContext?.delete(photo)
        }
        try? albumPlace.managedObjectContext?.save()
        
        // When a user requests a new collection,
        // if possible get a page other than
        // the default first page (value: 1)
        var pageNumber = 1
        if albumPlace.pageCount > 1 {
            let limit: Int = Int(albumPlace.pageCount)
            pageNumber = Int.random(in: 1 ..< limit)
        }

        // Download new photos
        searchPhotosOnline(page: pageNumber)
    }
    
    func getSavedPhotos() {
        // Get places sorted by id
        updateUI(state: .searching)
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        if let allPhotos = try? albumPlace.managedObjectContext!.fetch(fetchRequest) {
            // Only use the photos for this place
            placePhotos = allPhotos.filter({ (pp) -> Bool in
                return pp.place == albumPlace
            })
            
            // Sort photos by id
            placePhotos.sort(by: placeSorter(p1:p2:))
            
            if placePhotos.count > 0 {
                updateUI(state: .finished)
                photosCollectionView.reloadData()
            } else {
                searchPhotosOnline()
            }
        } else {
            searchPhotosOnline()
        }
    }
    
    func loadDownloadedPhotos(source: FlickrSearchResults) {
        let photoCount = source.photoCollection.photos.count
        if photoCount == 0 {
            updateUI(state: .empty)
        } else {
            placePhotos.removeAll()
            for onlinePhoto in source.photoCollection.photos {
                let offlinePhoto = Photo(context: albumPlace.managedObjectContext!)
                offlinePhoto.place = albumPlace
                offlinePhoto.farm = onlinePhoto.farm
                offlinePhoto.server = onlinePhoto.server
                offlinePhoto.id = onlinePhoto.id
                offlinePhoto.secret = onlinePhoto.secret
                try? albumPlace.managedObjectContext!.save()
                placePhotos.append(offlinePhoto)
            }
            
            // Save number of pages
            albumPlace.pageCount = source.photoCollection.pages 
            try? albumPlace.managedObjectContext!.save()
            
            // Sort photos by id
            placePhotos.sort(by: placeSorter(p1:p2:))
            
            photosCollectionView.reloadData()
            updateUI(state: .finished)
        }
    }
    
    func placeSorter(p1: Photo, p2: Photo) -> Bool {
        let result = p1.id!.compare(p2.id!)
        switch result {
        case ComparisonResult.orderedAscending:
            return true
        default:
            return false
        }
    }
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showAnnotation() {
        let pin = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: albumPlace.latitude, longitude: albumPlace.longitude)
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapView.setCenter(coordinate, animated: true)
        mapView.camera.altitude = cameraAltitude
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = false
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func updateCollectionViewImage(photo: Photo, imageData: Data, cell: PhotoCellView) {
        photo.data = imageData
        let image = UIImage(data: imageData)
        cell.imageView.image = image
    }
}
