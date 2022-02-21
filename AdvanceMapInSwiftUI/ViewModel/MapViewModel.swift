//
//  MapViewModel.swift
//  AdvanceMapInSwiftUI
//
//  Created by 1 on 21/09/21.
//

import SwiftUI
import MapKit
import CoreLocation

//All MapData goes here

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var mapView = MKMapView()
    
    // Region
    @Published var region: MKCoordinateRegion!
    //Based on Location it will set up
    
    // Alerting
    @Published var permissionDenied = false
    
    // Map type
    @Published var mapType : MKMapType = .standard
    
    // Search Text
    @Published var searchTxt = ""
    
    // Searched Place
    @Published var places : [PlaceModel] = []
    
    // Updating Map type
    func updateMapType() {
        if mapType == .standard {
            mapType = .hybrid
            mapView.mapType = mapType
        } else {
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    // Focus Location
    func focusLocation() {
        guard let _ = region else { return }
        
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    // Search
    func searchQuery() {
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTxt
        
        // Fetch
        MKLocalSearch(request: request).start { (response, error) in
            guard let result = response else { return }
            
            self.places = result.mapItems.compactMap({ mapItem -> PlaceModel? in
                return PlaceModel(placemark: mapItem.placemark)
            })
        } // MKlocalSearch
    } // function
    
    // Pick Search Result
    
    func selectPlace(place: PlaceModel) {
        //Showing Pin on Map
        
        searchTxt = ""
        
        guard let coordinate = place.placemark.location?.coordinate else { return }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.placemark.name ?? "No Name"
        
        // Removing All Old Ones
        mapView.removeAnnotations(mapView.annotations)
        
        mapView.addAnnotation(pointAnnotation)
        
        //moving Map to That location
        let coordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        //Cheking permission
        switch manager.authorizationStatus {
        case .denied:
            permissionDenied.toggle()
            //Alerting
        case .authorizedWhenInUse:
            manager.requestWhenInUseAuthorization()
            
        case .notDetermined:
            manager.requestLocation()
        default:
        ()
        
        } //: SWITCH
    } //function
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error.localizedDescription)
    } // function
    
    // Getting User location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
        // Updating Map
        self.mapView.setRegion(self.region, animated: true)
        
        //Smooth Animations
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
} //class
