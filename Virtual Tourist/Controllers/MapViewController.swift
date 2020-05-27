//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/25/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var longPressRecognizer: UILongPressGestureRecognizer!
    let albumViewControllerId = "albumViewController"
    let dataManager = DataManager()
    var pins: [Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        updateUI(waitingForDataManager: true)
        dataManager.load(handler: dataManagerLoaded)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPin))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: nil, action: nil)
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Set saved region (will restore center and zoom level)
        if let region = UserPrefManager.getMapRegion() {
            mapView.setRegion(region, animated: true)
        }
    }
    
    func updateUI(waitingForDataManager: Bool) {
        if waitingForDataManager {
            activityIndicator.startAnimating()
            loadingStackView.isHidden = false
            mapView.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            loadingStackView.isHidden = true
            mapView.isHidden = false
        }
    }
    
    func dataManagerLoaded() {
        // Get places
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let results = try? dataManager.context.fetch(fetchRequest) {
            pins = results
        }
        addPlaces()
        updateUI(waitingForDataManager: false)
    }
    
    func addPlaces() {
        for p in pins {
            let coordinate = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
            addPlaceAnnotation(coordinate: coordinate, pin: p)
        }
    }
    
    func addPlaceAnnotation(coordinate: CLLocationCoordinate2D, pin: Pin) {
        let annotation = PlaceAnnotation(pin)
        annotation.coordinate = coordinate
        annotation.title = "View album"
        mapView.addAnnotation(annotation)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        UserPrefManager.saveMapRegion(mapView.region) 
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
            pinView!.animatesDrop = true
            pinView!.pinTintColor = .red
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let albumController = storyboard?.instantiateViewController(withIdentifier: albumViewControllerId) as! PhotoAlbumViewController?, let placeAnnotation = view.annotation as! PlaceAnnotation? {
            albumController.cameraAltitude = mapView.camera.altitude
            albumController.albumPlace = placeAnnotation.pin
            if let navigator = navigationController {
                navigator.pushViewController(albumController, animated: true)
            }
        }
    }
    
    @objc func dropPin() {
        if longPressRecognizer.state == .began {
            let pressedPoint = longPressRecognizer.location(in: mapView)
            let coordinate = mapView.convert(pressedPoint, toCoordinateFrom: mapView)
            
            // Save pin
            let pin = Pin(context: dataManager.context)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            try? pin.managedObjectContext?.save()
            
            addPlaceAnnotation(coordinate: coordinate, pin: pin)
        }
    }
}

