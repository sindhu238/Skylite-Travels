//
//  PostLoginVC.swift
//  Skylite Travels
//
//  Created by Venkateswara on 15/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import SideMenu

class PostLoginVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var fromTV: UITextField!
    @IBOutlet weak var toTV: UITextField!
    @IBOutlet weak var mapview: MKMapView!
    
    private var locationManager: CLLocationManager!
    let regionRadius: CLLocationDistance = 1000
    var currentLocation : CLLocation!
    var destinationLocation: CLLocation!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuLeftNC = UISideMenuNavigationController()
        menuLeftNC.leftSide = true
        SideMenuManager.menuLeftNavigationController = menuLeftNC
        
      //  SideMenuManager.menuAddPanGestureToPresent(toView: (self.navigationController?.navigationBar)!)
      //  SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapview.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            currentLocation = getCurrentLocation()
        }
        
        destinationLocation = CLLocation(latitude: CLLocationDegrees(51.4711145), longitude: CLLocationDegrees(-0.3621214))
        
        let currentCoordinates = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        let destinationCoordinates = CLLocationCoordinate2DMake(destinationLocation.coordinate.latitude, destinationLocation.coordinate.longitude)
        
        let currentlocPlaceMarker = MKPlacemark(coordinate: currentCoordinates, addressDictionary: nil)
        let destlocPlaceMarker = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)

        let currentLocMapItem = MKMapItem(placemark: currentlocPlaceMarker)
        let destLocMapItem = MKMapItem(placemark: destlocPlaceMarker)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Current Location"
        if let location = currentlocPlaceMarker.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        
        let destinationAnnotation = MKPointAnnotation()

        destinationAnnotation.title = "Destination"
        
        if let location = destlocPlaceMarker.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapview.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = currentLocMapItem
        directionRequest.destination = destLocMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            let route = response.routes[0]
            self.mapview.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapview.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        
        return renderer
    }

    func getCurrentLocation()-> CLLocation {
        let currentLocation = locationManager.location!
        return currentLocation
    }
    
    @IBAction func onMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "menu", sender: nil)
       // present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        
    }
    
}
