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
import Alamofire

class PostLoginVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var toTV: LeftPaddedTF!
    @IBOutlet weak var fromTV: LeftPaddedTF!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var viewToAnimate: UIView!
    @IBOutlet weak var getQuoteBtn: UIButton!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var downArrow: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var passengerValue: UILabel!
    @IBOutlet weak var luggageValue: UILabel!
    
    var places : [Places] = []
    private var locationManager: CLLocationManager!
    let regionRadius: CLLocationDistance = 1000
    var sourceLocation : CLLocation!
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
    var geocode: CLGeocoder!

    var sourceAnnotation: MKPointAnnotation!
    var route: MKRoute!
    var changedSourceLoc = false
    var swapClicked = false
    var amount: Int!
    var price: Double!
    var vat: Double!
    var passengers: Int!
    var luggage: Int!
    var date: String!
    var time: String!
    
    @IBOutlet weak var luggageSlider: UISlider!
    @IBOutlet weak var passengerSlider: UISlider!
    @IBOutlet weak var datepicker: UIDatePicker!
    @IBOutlet weak var passlugView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.downloadDataFromFirebase()
    
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
            sourceLocation = getCurrentLocation()
        }
        
       
        
        sourceCoordinates = CLLocationCoordinate2DMake(sourceLocation.coordinate.latitude, sourceLocation.coordinate.longitude)
       
        
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
            self.mapview.isUserInteractionEnabled = false
            self.viewToAnimate.alpha = 1
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }

    // Gets current location and displays address in from text field
    func getCurrentLocation()-> CLLocation {
        let currentLocation = locationManager.location!
        geocode = CLGeocoder()
        geocode.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) in
            if let placemark = (placemarks?[0]) {
                let currentPlaceAddress = "\((placemark.addressDictionary?["Name"])!), \((placemark.addressDictionary?["Thoroughfare"])!), \((placemark.addressDictionary?["ZIP"])!)"
                self.fromTV.text = currentPlaceAddress
            }
        })

        return currentLocation
    }
    
    @IBAction func onMenuPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.viewToAnimate.bounds.origin.y == 0 {
            self.viewToAnimate.alpha = 0
            self.viewToAnimate.bounds.origin.y -= self.view.bounds.height
        } else {
            self.mapview.isUserInteractionEnabled = true
            self.getQuoteBtn.isUserInteractionEnabled = true
            self.toTV.isUserInteractionEnabled = true
            self.fromTV.isUserInteractionEnabled = true
        }
        self.passlugView.bounds.origin.y -= self.view.bounds.height
        self.passlugView.alpha = 0

        if fromTV.text != "" && toTV.text != "" {
            self.getQuoteBtn.alpha = 1
        }else {
            self.getQuoteBtn.alpha = 0
        }
    }
    
    
    @IBAction func onGetQuotePressed(_ sender: UIButton) {
        if fromTV.text != "" && toTV.text != "" {
            self.downloadPrice {
                self.downloadVat {
                    self.calculateDistance {
                        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
                           self.passlugView.alpha = 1
                            self.passlugView.bounds.origin.y += self.view.bounds.height

                        }, completion: nil)
                    }
                }
            }
        }
    }
    
    func downloadPrice(completed: @escaping DownloadComplete) {
        let dbReference = FIRDatabase.database().reference()
        dbReference.child("Price").observeSingleEvent(of: .value, with: { (snapshot) in
            self.price = snapshot.value! as! Double
            completed()
        })
        { (error) in
            print("Error in getting price details from Firebase \(error.localizedDescription)")
        }
    }
    
    func downloadVat(completed: @escaping DownloadComplete) {
        let dbReference = FIRDatabase.database().reference()
        dbReference.child("VAT").observeSingleEvent(of: .value, with: { (snapshot) in
            let temp = snapshot.value! as! String
            self.vat = Double(temp)
            completed()
        })
        { (error) in
            print("Error in getting vat details from Firebase \(error.localizedDescription)")
        }
    }
    
    func calculateDistance(completed: @escaping DownloadComplete) {
        let url = "\(base_url)units=imperial&origins=\(sourceLocation.coordinate.latitude),\(sourceLocation.coordinate.longitude)&destinations=\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)&key=\(API_KEY)"
        
        Alamofire.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let json):
                let dict = json as! Dictionary<String, AnyObject>
                let rows = dict["rows"] as! [Dictionary<String, AnyObject>]
                let elements = rows[0]["elements"] as! [Dictionary<String, AnyObject>]
                let distance = elements[0]["distance"] as! Dictionary<String, AnyObject>
                let text = distance["text"] as! String
                let lastindex = text.index(text.endIndex, offsetBy: -3)
                let dist: String = text.substring(to: lastindex)
                self.amount = Int(round((round(Double(dist)!) * self.price) + (round(Double(dist)!) * self.price * self.vat/100)))
                
            case .failure(let error):
                print("Error in getting distance from google maps \(error.localizedDescription)")
            }
            completed()
        }
    }


    @IBAction func onDownArrowClicked(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.viewToAnimate.alpha = 0
            self.viewToAnimate.bounds.origin.y -= self.view.bounds.height
           
        }, completion:{finished in
            if finished {
                self.mapview.isUserInteractionEnabled = true
                self.getQuoteBtn.isUserInteractionEnabled = true
                self.toTV.isUserInteractionEnabled = true
                self.fromTV.isUserInteractionEnabled = true
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
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
       let placeName = self.places[indexPath.row].placeName
        if fromTVSelected {
            fromTV.text = placeName
            changedSourceLoc = true
        } else if toTVSelected {
            toTV.text = placeName
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.viewToAnimate.alpha = 0
            self.viewToAnimate.bounds.origin.y -= self.view.bounds.height
            print(" 1 \(self.viewToAnimate.bounds.origin.y)")

            
        }, completion:{finished in
            if finished {
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
            if self.fromTV.text != "" && self.toTV.text != "" {
                self.getQuoteBtn.alpha = 1
            }
        })
    }
    
    @IBAction func onSwapClicked(_ sender: UIButton) {
        if fromTV.text != "" && toTV.text != "" {
            if route != nil {
                mapview.remove(route.polyline)
            }
            mapview.removeAnnotations([sourceAnnotation,destinationAnnotation])

            let tempLocation = sourceLocation
            sourceLocation = destinationLocation
            destinationLocation = tempLocation
            
            let tempMapItem = sourceLocMapItem
            sourceLocMapItem = destLocMapItem
            destLocMapItem = tempMapItem

            let tempAnnotaion = sourceAnnotation
            sourceAnnotation = destinationAnnotation
            destinationAnnotation = tempAnnotaion
            destinationAnnotation.title = "Destination"
            sourceAnnotation.title = "From Location"
            print("des \(sourceAnnotation.coordinate.latitude)  \(sourceAnnotation.coordinate.longitude)  \(self.destinationAnnotation.coordinate.latitude)    \(self.destinationAnnotation.coordinate.longitude)")

            swapClicked = true
            mapview.addAnnotations([sourceAnnotation,destinationAnnotation])
            drawRoute(source: sourceLocMapItem, destination: destLocMapItem)
        } else if toTV.text == ""{
            destinationLocation = sourceLocation
            destinationAnnotation = sourceAnnotation
            destinationAnnotation.title = "Destination"
            destlocPlaceMarker = sourcelocPlaceMarker
            destLocMapItem = sourceLocMapItem
        }else if fromTV.text == "" {
            sourceLocation = destinationLocation
            sourceAnnotation = destinationAnnotation
            sourceAnnotation.title = "From Location"
            sourcelocPlaceMarker = destlocPlaceMarker
            sourceLocMapItem = destLocMapItem
        }
        
        let temp = fromTV.text
        fromTV.text = toTV.text
        toTV.text = temp
    }
    
    //When destination is selected it calucates coordinates for source and destination and displays annotations
    func routeMap(place: Places, text: String) {
        if route != nil {
            mapview.removeAnnotation(sourceAnnotation)
            mapview.removeAnnotation(destinationAnnotation)
            mapview.remove(route.polyline)
        }
    
        if text == "from" {
            self.changeSource(place: place)
        }
        
        else {
            destinationLocation = CLLocation(latitude: CLLocationDegrees(place.latitude), longitude: CLLocationDegrees(place.longitude))
            destinationCoordinates = CLLocationCoordinate2DMake(destinationLocation.coordinate.latitude, destinationLocation.coordinate.longitude)
            destlocPlaceMarker = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
            destLocMapItem = MKMapItem(placemark: destlocPlaceMarker)
            destinationAnnotation = MKPointAnnotation()
            
            self.destinationAnnotation.title = "Destination"
            if let location = destlocPlaceMarker.location {
                self.destinationAnnotation.coordinate = location.coordinate
            }
            
        }
        
        self.mapview.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true )

        
        
        drawRoute(source: sourceLocMapItem, destination: destLocMapItem)
    }
    
    //When source location is changed from given current location then it calculates the coordinates for source
    func changeSource(place: Places) {
        self.mapview.removeAnnotation(self.sourceAnnotation)
        self.sourceLocation = CLLocation(latitude: CLLocationDegrees(place.latitude), longitude: CLLocationDegrees(place.longitude))
        sourceCoordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
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
    
    @IBAction func onPassCloseClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "quoteVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.date == nil || self.time == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.date = dateFormatter.string(from: self.datepicker.date)
            dateFormatter.dateFormat = "HH:mm"
            self.time = dateFormatter.string(from: self.datepicker.date)
        }
        if passengers == nil {
            self.passengers = 1
        }
        if self.luggage == nil {
            self.luggage = 0
        }
        if let destination = segue.destination as? QuoteVC {
            destination.from = self.fromTV.text
            destination.to = self.toTV.text
            destination.date = "\(self.date!), \(self.time!)"
            destination.passLug = "\(self.passengers!)/\(self.luggage!)"
            destination.amt = "\(self.amount!)£"
        }
        
    }
    
    @IBAction func datepickerClicked(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.date = dateFormatter.string(from: sender.date)
        dateFormatter.dateFormat = "HH:mm"
        self.time = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func passengerSlider(_ sender: UISlider) {
        self.passengers = Int(sender.value)
        passengerValue.text = "\(self.passengers!)"
    }
    
    @IBAction func luggageSlider(_ sender: UISlider) {
        self.luggage = Int(sender.value)
        luggageValue.text = "\(self.luggage!)"
    }
}
