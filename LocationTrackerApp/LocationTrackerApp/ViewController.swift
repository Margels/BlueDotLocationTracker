//
//  ViewController.swift
//  LocationTrackerApp
//
//  Created by Martina on 06/04/22.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController {
    
    // Storyboard
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var locationsTableView: UITableView!
    @IBOutlet var displayMessage: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var zoomInButton: UIButton!
    @IBOutlet var zoomOutButton: UIButton!
    @IBOutlet var distanceLabel: UILabel!
    
    // Definitions
    var locationManager = CLLocationManager()
    var lastLocation = CLLocationCoordinate2D()
    var currentLocation = CLLocationCoordinate2D()
    var events: [event] = []
    var delta: Double = 0.005
    var distance: Int = 0
    
    struct event {
        
        var location = CLLocationCoordinate2D()
        var name = String()
        var time = Date()
        
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display message to alert >10m movements
        displayMessage.layer.cornerRadius = displayMessage.frame.height / 2
        displayMessage.alpha = 0
        displayMessage.isUserInteractionEnabled = false
        
        // Table view
        locationsTableView.delegate = self
        locationsTableView.dataSource = self
        let view = UIView()
        locationsTableView.tableFooterView = view
        
        // Map view
        mapView.delegate = self
        mapView.layer.cornerRadius = 30
        mapView.layer.borderWidth = 0.5
        mapView.layer.borderColor = UIColor.lightGray.cgColor
        
        // Zoom buttons
        for button in [zoomInButton, zoomOutButton] {
            button!.layer.cornerRadius = button!.frame.height / 2
        }
        
        // Loc manager auth
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        // Start detecting location
        detectLocation()
        
    }
    
    
    // Turn coordinates into location name (st, city etc)
    func convert(lat: Double, lon: Double, completion: @escaping (String)->Void) {
        
        print("converting...")
        let loc = CLLocation(latitude: lat, longitude: lon)
        let geoCoder = CLGeocoder()
        
        // reverse geocode
        geoCoder.reverseGeocodeLocation(loc) { placemark, error in
            
            // error handler
            if let error = error {
                print("converting error - \(error)") }
            
            // check that placemark exists
            guard let pm = placemark else {
                print("converting failed, no placemark")
                return }
            
            // retrieve steet, zip code, city, province/state
            if let s = pm[0].thoroughfare,
               let z = pm[0].postalCode,
               let c = pm[0].locality,
               let p = pm[0].administrativeArea {

                // create string
                let string = "\(s)\n\(z) \(c) \(p)"
                completion(string)
                print("string: \(string)")
                
                }
            }
        }
    

    // detect user's location
    func detectLocation() {
        
        // best accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // proceed once user has granted permission
        if CLLocationManager.locationServicesEnabled() {
            print("Detecting user's location...")
            locationManager.startUpdatingLocation()
            
        }
        
    }

    
    func moveMessage(string: String) {
        
        if let ml = messageLabel, let dm = displayMessage {
            
            // message
            ml.text = string
            dm.alpha = 0.9
            
            // animation
            UIView.animate(withDuration: 5) {
                dm.alpha = 0
            
            }
            
        }
        
    }
    
    
    func updateDistance(meters: Int) {
        
        // only update after first location detected
        if events.count >= 1 {
            distance += meters
            if let dl = distanceLabel {
                dl.text = "Total distance so far: \(distance)m"
            
            }
            
        }
        
    }
    
    
    // custom movement message
    func displayMovementMessage(meters: Int, location: CLLocation) {
        
        if meters > 10 || events.count == 0 {
            
            print("User moved 10 meters or more.")
            
            // display message that quickly goes away on its own
            moveMessage(string: "Yay! You just moved \(meters)m!")
            print("distance test, mt \(meters)")
            
            // change last location reference
            lastLocation = currentLocation
            
            // add to total & update message
            updateDistance(meters: meters)
            
            // add the event at the top of the list for the user
            self.events.insert(event(location: location.coordinate,
                                     time: Date()),
                               at: 0)
            
            // reload table view
            if let tv = locationsTableView {
                
                tv.reloadData()
                
            }
            
        }
        
    }
    
    
    // calculate distance: current location (cl) vs last location (ll)
    func calculateDistance(location: CLLocation) -> Int {
        
        // current
        let cl = location
        
        // previous
        let ll = CLLocation(latitude: lastLocation.latitude,
                            longitude: lastLocation.longitude)
        
        // distance
        let dist = Int(cl.distance(from: ll))
        
        // result
        return dist
        
    }
    
    
    
    
    @IBAction func zoomIn(_ sender: Any) {
        
        delta = delta > 0.001 ? delta-0.001 : delta
        mapView.region.span = MKCoordinateSpan(latitudeDelta: delta,
                                               longitudeDelta: delta)
        
    }
    
    
    @IBAction func zoomOut(_ sender: Any) {
        
        delta = delta < 0.025 ? delta+0.001 : delta
        mapView.region.span = MKCoordinateSpan(latitudeDelta: delta,
                                               longitudeDelta: delta)
        
    }
    
    
    

}


// MARK: - Table View

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of locations retrieved
        return events.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! tableViewCell
        let ref = events[indexPath.row]
        
        // tell the user the name of the location
        convert(lat: ref.location.latitude, lon: ref.location.longitude) { String in
            cell.label.text = "\(String)"
        }
        
        // tell the user how long ago they were at that location
        let time = ref.time.timeIntervalSinceNow
        let now = Date().addingTimeInterval(time)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let str = formatter.localizedString(for: now, relativeTo: Date())
        cell.desc.text = indexPath.row == 0 ? "now" : "\(str)"; print("difference: \(str)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Move events >10m"
    }
    
    
    
}

// MARK: - Table view cell

class tableViewCell: UITableViewCell {
    
    @IBOutlet var picture: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var desc: UILabel!
    
}


// MARK: - MapKit

extension ViewController: MKLocalSearchCompleterDelegate, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }

    
}




// MARK: - Core Location Delegate

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // retrieve location data
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        
        // update current location (cl) property
        currentLocation = center
        let region = MKCoordinateRegion(center: center,
                                        span: MKCoordinateSpan(latitudeDelta: delta,
                                                               longitudeDelta: delta))
        let cl = CLLocation(latitude: region.center.latitude,
                            longitude: region.center.longitude)
        
        // update map
        self.mapView.setRegion(region,
                               animated: true)
        
        // calc distance
        let dist = calculateDistance(location: cl)
        
        // print location data
        print("location = \(locValue.latitude) \(locValue.longitude)\n difference in mt: \(dist)")
        
        // if distance is over 10m or if it's the first location event
        displayMovementMessage(meters: Int(dist), location: cl)
        
        
    }
    
}
