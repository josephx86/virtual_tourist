//
//  UserPrefManager.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/25/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation
import MapKit

class UserPrefManager {
    class func getMapRegion() -> MKCoordinateRegion? {
        guard let span = getMapRegionSpan() else {
            return nil
        }
        
        guard let center = getMapCenter() else {
            return nil
        }
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    fileprivate class func getMapCenter() -> CLLocationCoordinate2D? {
        // Get latitude
        guard let mapCenterLatitude = UserDefaults.standard.value(forKey: UserPrefs.mapCenterLatitude.rawValue) as! Double? else {
            return nil
        }
        
        // Get longitude
        guard let mapCenterLongitude = UserDefaults.standard.value(forKey: UserPrefs.mapCenterLongitude.rawValue) as! Double? else {
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: mapCenterLatitude, longitude: mapCenterLongitude)
    }
    
    fileprivate class func getMapRegionSpan() -> MKCoordinateSpan? {
        // Get latitude
        guard let latitudeDelta = UserDefaults.standard.value(forKey: UserPrefs.mapRegionSpanLatitudeDelta.rawValue) as! Double? else {
            return nil
        }
        
        // Get longitude
        guard let longitudeDelta = UserDefaults.standard.value(forKey: UserPrefs.mapRegionSpanLongitudeDelta.rawValue) as! Double? else {
            return nil
        }
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    class func saveMapRegion(_ region: MKCoordinateRegion) {
        saveMapRegionSpan(region.span)
        saveMapCenter(region.center)
    }
    
    fileprivate class func saveMapCenter(_ center: CLLocationCoordinate2D) {
        UserDefaults.standard.set(center.latitude, forKey: UserPrefs.mapCenterLatitude.rawValue)
        UserDefaults.standard.set(center.longitude, forKey: UserPrefs.mapCenterLongitude.rawValue) 
    }
    
    fileprivate class func saveMapRegionSpan(_ span: MKCoordinateSpan) {
        UserDefaults.standard.set(span.latitudeDelta, forKey: UserPrefs.mapRegionSpanLatitudeDelta.rawValue)
        UserDefaults.standard.set(span.longitudeDelta, forKey: UserPrefs.mapRegionSpanLongitudeDelta.rawValue)
    }
}
