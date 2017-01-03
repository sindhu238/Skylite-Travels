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

class PostLoginVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var toTV: LeftPaddedTF!
    @IBOutlet weak var fromTV: LeftPaddedTF!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var viewToAnimate: UIView!
    @IBOutlet weak var getQuoteBtn: UIButton!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var downArrow: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //View behind viewToAnimate
    var view1 : UIView!
    
    var places : [Places] = []
    private var locationManager: CLLocationManager!
    let regionRadius: CLLocationDistance = 1000
    var currentLocation : CLLocation!
    var destinationLocation: CLLocation!
    var fromTVSelected = false
    var toTVSelected = false
    var destinationCoordinates: CLLocationCoordinate2D!
    var destlocPlaceMarker: MKPlacemark!
    var destLocMapItem: MKMapItem!
    var destinationAnnotation: MKPointAnnotation!
    var sourceCoordinates: CLLocationCoordinate2D!
    var sourcelocPlaceMarker: MKPlacemark!
    var sourceLocMapItem: MKMapItem!

    var sourceAnnotation: MKPointAnnotation!
    var route: MKRoute!
    var changedSourceLoc = false
    var swapClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadDataFromFirebase()
        view1 = UIView(frame: CGRect(x: 10, y: (self.view.bounds.height - self.viewToAnimate.bounds.height), width: self.viewToAnimate.bounds.width , height: self.viewToAnimate.bounds.height))
        
        self.toTV.isUserInteractionEnabled = true
        self.fromTV.isUserInteractionEnabled = true
        let menuLeftNC = UISideMenuNavigationController()
        menuLeftNC.leftSide = true
        SideMenuManager.menuLeftNavigationController = menuLeftNC
        SideMenuManager.menuAnimationFadeStrength = 5
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapview.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            currentLocation = getCurrentLocation()
        }
        
       
        
        sourceCoordinates = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
       
        
        sourcelocPlaceMarker = MKPlacemark(coordinate: sourceCoordinates, addressDictionary: nil)
       

        sourceLocMapItem = MKMapItem(placemark: sourcelocPlaceMarker)
               
        sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Current Location"
        if let location = sourcelocPlaceMarker.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        
        self.mapview.showAnnotations([sourceAnnotation], animated: true )
        
        toTV.addTarget(self, action: #selector(textFieldEditing), for: UIControlEvents.touchDown)
        fromTV.addTarget(self, action: #selector(textFieldEditing), for: UIControlEvents.touchDown)
        
//        self.tableView.estimatedRowHeight = 100.0
//        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func textFieldEditing(textfield: UITextField) {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        
        if textfield.tag == 0 {
            fromTVSelected = true
            toTVSelected = false

        }
        
        else if textfield.tag == 1 {
            toTVSelected = true
            fromTVSelected = false
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            self.viewToAnimate.isUserInteractionEnabled = true
            self.view1.isUserInteractionEnabled = true
            self.mapview.isUserInteractionEnabled = false
            self.viewToAnimate.bounds.origin.y += self.view.bounds.height
            self.tableView.reloadData()
            
        }, completion:{ finished in
            if finished {
                self.getQuoteBtn.isUserInteractionEnabled = false
                self.toTV.isUserInteractionEnabled = false
                self.fromTV.isUserInteractionEnabled = false
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(view1)
        self.view1.isUserInteractionEnabled = false
        view1.alpha = 1
        view1.addSubview(viewToAnimate)
        self.viewToAnimate.bounds.origin.y -= self.view.bounds.height
        self.view.layoutIfNeeded()
    }
    
    
    @IBAction func onGetQuotePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func onSwapClicked(_ sender: UIButton) {
        let temp = fromTV.text
        fromTV.text = toTV.text
        toTV.text = temp
        if fromTV.text != "" && toTV.text != "" {
            swapClicked = true
            mapview.remove(route.polyline)
            drawRoute(source: destLocMapItem, destination: sourceLocMapItem)
        }
    }
    
    @IBAction func onDownArrowClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.viewToAnimate.bounds.origin.y -= self.view.bounds.height
           
        }, completion:{finished in
            if finished {
                self.view1.isUserInteractionEnabled = false
                self.mapview.isUserInteractionEnabled = true
                self.getQuoteBtn.isUserInteractionEnabled = true
                self.toTV.isUserInteractionEnabled = true
                self.fromTV.isUserInteractionEnabled = true
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "placesCell") as? PlacesTVCell {
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .blue
            cell.configure(places: places[indexPath.row])
            return cell
        } else {
            return PlacesTVCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let placeName = self.places[indexPath.row]._placeName
        if fromTVSelected {
            fromTV.text = placeName
            changedSourceLoc = true
        } else if toTVSelected {
            toTV.text = placeName
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.viewToAnimate.bounds.origin.y -= self.view.bounds.height
            
        }, completion:{finished in
            if finished {
                self.view1.isUserInteractionEnabled = false
                self.mapview.isUserInteractionEnabled = true
                self.getQuoteBtn.isUserInteractionEnabled = true
                self.toTV.isUserInteractionEnabled = true
                self.fromTV.isUserInteractionEnabled = true
                if self.fromTVSelected {
                    self.changeSource(place: self.places[indexPath.row])
                    self.mapview.showAnnotations([self.sourceAnnotation], animated: true)
                    let region = MKCoordinateRegionMakeWithDistance(self.sourceCoordinates, 1000, 5000.0)
                    self.mapview.setRegion(region, animated: true)
 
                }
                if self.fromTV.text != "" && self.toTV.text != "" {
                    if self.fromTVSelected {
                        self.routeMap(place: self.places[indexPath.row], text: "from")
                    } else {
                        self.routeMap(place: self.places[indexPath.row], text: "to")
                    }
                }
            }
        })
    }
    
    func routeMap(place: Places, text: String) {
        if destinationLocation != nil {
            mapview.removeAnnotation(sourceAnnotation)
            mapview.removeAnnotation(destinationAnnotation)
            mapview.remove(route.polyline)
        }
    
        if text == "from" {
            self.changeSource(place: place)
        }
        
        else {
            destinationLocation = CLLocation(latitude: CLLocationDegrees(place._latitude), longitude: CLLocationDegrees(place.longitude))
            destinationCoordinates = CLLocationCoordinate2DMake(destinationLocation.coordinate.latitude, destinationLocation.coordinate.longitude)
            destlocPlaceMarker = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
            destLocMapItem = MKMapItem(placemark: destlocPlaceMarker)
            destinationAnnotation = MKPointAnnotation()
            
            self.destinationAnnotation.title = "Destination"

        }
        self.mapview.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true )

        if let location = destlocPlaceMarker.location {
            self.destinationAnnotation.coordinate = location.coordinate
        }
        
        drawRoute(source: sourceLocMapItem, destination: destLocMapItem)
    }
    
    func changeSource(place: Places) {
        self.mapview.removeAnnotation(self.sourceAnnotation)
        sourceCoordinates = CLLocationCoordinate2DMake(place._latitude, place._longitude)
        sourcelocPlaceMarker = MKPlacemark(coordinate: sourceCoordinates, addressDictionary: nil)
        sourceLocMapItem = MKMapItem(placemark: sourcelocPlaceMarker)
        sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "From Location"
        if let location = sourcelocPlaceMarker.location {
            sourceAnnotation.coordinate = location.coordinate
        }
    }

    // Function that draws a polyline between source and destination
    func drawRoute(source: MKMapItem, destination: MKMapItem) {
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = source
        directionRequest.destination = destination
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error in maps: \(error)")
                }
                
                return
            }
            if self.swapClicked {
                let temp = self.sourceAnnotation.title
                self.sourceAnnotation.title = self.destinationAnnotation.title
                self.destinationAnnotation.title = temp
                self.mapview.remove(self.route.polyline)
                self.swapClicked = false
            }
            self.route = response.routes[0]
            
            self.mapview.add((self.route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = self.route.polyline.boundingMapRect
            self.mapview.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)

        }
    }
    func downloadDataFromFirebase() {
        let ref = FIRDatabase.database().reference()
        ref.child("Places").child("Airport").queryOrdered(byChild: "category").queryEqual(toValue: "Airport").observe(.value , with: { snapshot in
            for child in snapshot.children {
                let item = child as! FIRDataSnapshot
                let placeName = item.childSnapshot(forPath: "placename").value as! String
                let address = item.childSnapshot(forPath: "address").value as! String
                let latitude = item.childSnapshot(forPath: "latitude").value as! Double
                let longitude = item.childSnapshot(forPath: "longitude").value as! Double
                let category = item.childSnapshot(forPath: "category").value as! String
                let zipcode = item.childSnapshot(forPath: "zipcode").value as! String
                let place = Places(placeName: placeName, address: address, latitude: latitude, longitude: longitude, category: category, zipcode: zipcode)
                self.places.append(place)

            }
        })
    }
}
