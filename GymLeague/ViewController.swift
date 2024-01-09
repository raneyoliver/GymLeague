//
//  ViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/29/23.
//

import GooglePlaces
import UIKit
import FirebaseFirestore
import GoogleSignIn
import MapKit

struct Place {
    let name: String
    let types: [String]
}

class ViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    
    let gymCheckButton = UIButton() // Create a button
    
    var myButton = GymButton()
    
    @IBOutlet weak var typesLabel: UILabel!
    private var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    var db: Firestore!
    
    var currentAddress:String!
    var lastLocationUpdate: Date?

    var mapView: MKMapView!
    var mapViewContainer: UIView!

    var tableView: UITableView!
    var places = [Place]()
    
    var workoutZoneOverlay: MKCircle!
    var countdownTimer: Timer!
    
    let minimumWorkoutTime = 10 //20 * 60 // 20 minutes in seconds
    var timeLeft:Int!
    let radiusInMeters:Double = 100
    
    let gymTypes = ["gym", "establishment", "point_of_interest"]
    let nonGymTypes = ["locality", "political", "country", "administrative_area_level_1", "administrative_area_level_2"]

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Request permission and start updating locations
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop updating locations when the view is no longer visible
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // Configure locationManager settings
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters  // Adjust based on your needs
        locationManager.distanceFilter = 10  // Minimum change in distance (meters) for update
        

        // Start receiving location updates
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        db = Firestore.firestore()
                
        myButton = GymButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        myButton.setTitle("Check In", for: .normal)
        myButton.center = view.center
        view.addSubview(myButton)
        myButton.addTarget(self, action: #selector(checkInToGym), for: .touchUpInside)
        
        setupMapContainerView()
        setupTableView()

    }
    
    func setupMapContainerView() {
        mapViewContainer = UIView(frame: CGRect(x: 20, y: 100, width: self.view.bounds.width - 40, height: 300)) // Adjust frame as needed
        mapViewContainer.backgroundColor = .lightGray // So you can see the container
        mapViewContainer.isHidden = true
        view.addSubview(mapViewContainer)
        
        // Now add the map view to this container
        setupMapView()
    }

    func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        mapViewContainer.addSubview(mapView)
        
        // Set map view to fill the container
        mapView.frame = CGRect(x: 0, y: 0, width: mapViewContainer.frame.width, height: mapViewContainer.frame.height)
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = CustomBackgroundView.color
        
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaceCell")

        view.addSubview(tableView)
        
        // Set tableView frame or constraints here
        // Example frame setup
        tableView.frame = CGRect(x: 5, y: mapViewContainer.frame.maxY, width: view.bounds.width - 10, height: view.bounds.height - mapViewContainer.frame.maxY)
    }
    
    @objc func checkInToGym() {
        // Hide the button
        myButton.isHidden = true
        
        // Show the map
        mapViewContainer.isHidden = false
        
        tableView.isHidden = true
        
        timeLeft = minimumWorkoutTime
        
        if let userLocation = locationManager.location {
            // Center the map at user's current location
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: true)
            
            // Add circular overlay to the map
            workoutZoneOverlay = MKCircle(center: userLocation.coordinate, radius: radiusInMeters)
            mapView.addOverlay(workoutZoneOverlay)
        }
        
        // Start the countdown timer
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if timeLeft > 0 {
            timeLeft -= 1
            // Update your label or annotation on the map with the remaining time
            updateMapAnnotationWithTime()
        } else {
            countdownTimer.invalidate()
            // Handle completion of the 20-minute period
            handleWorkoutCompletion()
        }
    }

    func updateMapAnnotationWithTime() {
        // Remove old annotations and add a new one with the updated time
        let timeAnnotation = MKPointAnnotation()
        timeAnnotation.coordinate = workoutZoneOverlay.coordinate
        let minutes = timeLeft / 60
        timeAnnotation.title = "Stay within this area for \(minutes > 0 ? "\(minutes) minutes and " : "")\(timeLeft % 60) seconds!"
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(timeAnnotation)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circleOverlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
            circleRenderer.strokeColor = UIColor.blue
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func handleWorkoutCompletion() {
        // Do something when the workout is completed
        // Maybe show a congratulatory message or log the workout
        mapViewContainer.isHidden = true
        tableView.isHidden = false
        myButton.isHidden = false
        timeLeft = minimumWorkoutTime
        print("workout complete!")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !mapViewContainer.isHidden { return }
        
        guard let location = locations.last else { return }
        
        // Check if at least 5 seconds have passed since the last update
        if let lastUpdate = lastLocationUpdate, Date().timeIntervalSince(lastUpdate) < 5 {
            return  // Less than 5 seconds passed, ignoring this update
        }
        
        lastLocationUpdate = Date()  // Update the timestamp
        
        // Now, use the Google Places API to check for nearby gyms
        checkForNearbyGyms(location: location) { isNearby in
            if isNearby {
                print("User is within radius of a relevant location")
            } else {
                print("No relevant locations found within radius.")
            }
            
            DispatchQueue.main.async {
                self.gymCheckButton.isEnabled = isNearby
            }
        }
        
    }
    
    func checkForNearbyGyms(location: CLLocation, completion: @escaping (Bool) -> Void) {
        // Recursive function to try the next type if the current one fails
        func tryNextType(index: Int) {
            if index >= gymTypes.count {
                completion(false)  // No more types to try
                return
            }
            
            isTypeNearby(location: location, type: gymTypes[index]) { found in
                if found {
                    completion(true)  // Found places of the current type
                } else {
                    tryNextType(index: index + 1)  // Try the next type
                }
            }
        }
        
        tryNextType(index: 0)  // Start with the first type
    }
    
    
    func locationString(from location: CLLocation) -> String {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let coordinateString = "\(latitude),\(longitude)"
        
        // URL-encode the coordinate string
        return coordinateString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    func isTypeNearby(location: CLLocation, type: String, completion: @escaping (Bool) -> Void) {
        let locationString = locationString(from: location)
        
        let apiKey = Config.getGooglePlacesAPIKey()
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locationString)&radius=\(radiusInMeters)&type=\(type)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching places: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    
                    for result in results {
                        if let name = result["name"] as? String,
                           let types = result["types"] as? [String],
                           self.isGym(types),
                           !self.places.contains(where: { $0.name == name }) {

                            // Add the place if it's not already in the list
                            let newPlace = Place(name: name, types: types)
                            self.places.append(newPlace)
                        }
                        
                        print(result)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    // If any results are found, return true, otherwise false
                    completion(!results.isEmpty)
                } else {
                    completion(false)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(false)
            }
        }
        task.resume()
    }
    
    func isGym(_ types: [String]) -> Bool {
        return !types.contains(where: nonGymTypes.contains)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceTableViewCell else {
            fatalError("Could not dequeue PlaceTableViewCell")
        }
        
        let place = places[indexPath.row]
        cell.configure(with: place)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    // Add a UIButton in Interface Builder, and connect the action to this function.
//    @IBAction func getCurrentPlace(_ sender: UIButton) {
//        let placeFields: GMSPlaceField = [.name, .formattedAddress, .types]
//        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
//            guard let strongSelf = self else {
//                return
//            }
//
//            guard error == nil else {
//                print("Current place error: \(error?.localizedDescription ?? "")")
//                return
//            }
//
//            guard let place = placeLikelihoods?.first?.place else {
//                strongSelf.nameLabel.text = "No current place"
//                strongSelf.addressLabel.text = ""
//                return
//            }
//
//            strongSelf.currentAddress = place.name
//            strongSelf.isGym = place.types!.contains("gym") || place.types!.contains("point_of_interest") || place.types!.contains("establishment")
//
//            // Check if the types include "gym"
//            if place.types?.contains("gym") ?? false {
//                // The place is a gym
//                strongSelf.nameLabel.text = place.name
//                strongSelf.addressLabel.text = place.formattedAddress
//                strongSelf.typesLabel.text = place.types?.joined(separator: "\n")
//                // Handle the logic for the user being at a gym
//            } else {
//                // The place is not a gym
//                strongSelf.nameLabel.text = "Not a gym"
//                strongSelf.addressLabel.text = place.formattedAddress
//                strongSelf.typesLabel.text = place.types?.joined(separator: "\n")
//                // Handle accordingly
//            }
//
//        }
//
//    }
    
    
    
}


