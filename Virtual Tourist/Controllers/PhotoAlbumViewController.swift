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

enum CollectionState {
    case searching
    case empty
    case finished
}

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        }
    }
    
    func searchPhotosOnline() {
        updateUI(state: .searching)
        HttpHelper.searchPhotos(latitude: albumPlace.latitude, longitude: albumPlace.longitude, onSuccess: loadDownloadedPhotos, onError: showMessage)
    }
    
    @IBAction func newCollection(_ sender: Any) {
        updateUI(state: .searching)
        
        // Delete any saved photos
        while (placePhotos.count > 0) {
            let photo = placePhotos.remove(at: 0)
            albumPlace.managedObjectContext?.delete(photo)
        }
        try? albumPlace.managedObjectContext?.save()
        
        // Download new photos
        searchPhotosOnline()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = placePhotos[indexPath.row]
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as! PhotoCellView 
        if let data = photo.data {
            cell.imageView.image = UIImage(data: data)
        } else {
            HttpHelper.downloadPhoto(photo: photo, cell: cell, onSuccess: updateCollectionViewImage(photo:imageData:cell:))
        }
        
        return cell
    }
    
    func updateCollectionViewImage(photo: Photo, imageData: Data, cell: PhotoCellView) {
        photo.data = imageData
        let image = UIImage(data: imageData)
        cell.imageView.image = image
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ask if user wants to delete.
        let question = UIAlertController(title: "Confirm delete", message: "Are you sure you sure you want to delete the selected photo?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Yes, Delete", style: .destructive) { (_) in
            // Delete the photo
            collectionView.deleteItems(at: [indexPath])
            let photo = self.placePhotos.remove(at: indexPath.row)
            photo.managedObjectContext?.delete(photo)
            try? photo.managedObjectContext?.save()
        }
        question.addAction(cancelAction)
        question.addAction(deleteAction)
        present(question, animated: true)
    }
}
