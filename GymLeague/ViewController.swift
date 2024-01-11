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
    let coordinate: CLLocationCoordinate2D
    let photoReference: String?
    var image:UIImage?
}

class ViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, PlaceTableViewCellDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noGymsLabel: UILabel!
    let gymCheckButton = UIButton() // Create a button
    
    var myButton = GymButton()
    
    private var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    var db: Firestore!
    
    var currentAddress:String!
    var lastLocationUpdate: Date?

    var mapView: MKMapView!
    var mapViewContainer: UIView!

    var tableView: UITableView!
    var places = [Place]()
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    var workoutZoneOverlay: MKCircle!
    var countdownTimer: Timer!
    
    let minimumWorkoutTime = 10 //20 * 60 // 20 minutes in seconds
    var timeLeft:Int!
    let workoutRadiusInMeters:Double = 100
    let searchRadiusInMeters:Double = 50
    
    let gymTypes = ["gym", "establishment", "point_of_interest"]
    let nonGymTypes = ["route", "locality", "political", "country", "administrative_area_level_1", "administrative_area_level_2", "parking", "grocery_or_supermarket"]

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Request permission and start updating locations
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//        }
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
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//        }
        db = Firestore.firestore()
                
        myButton = GymButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        myButton.setTitle("Start", for: .normal)
        myButton.center = view.center
        myButton.isHidden = false
        view.addSubview(myButton)
        myButton.addTarget(self, action: #selector(startWorkoutProcess), for: .touchUpInside)
        
        noGymsLabel.isHidden = true
        
        setupMapContainerView()
        setupTableView()
        setupSpinner()

        
        titleLabel.text = "Start a workout"

    }
    
    func setupSpinner() {
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupMapContainerView() {
        mapViewContainer = UIView(frame: CGRect(x: 20, y: 100, width: self.view.bounds.width - 40, height: 300)) // Adjust frame as needed
        mapViewContainer.backgroundColor = .lightGray // So you can see the container
        mapViewContainer.isHidden = true
        mapViewContainer.layer.cornerRadius = 8
        mapViewContainer.clipsToBounds = true
        mapViewContainer.center = view.center
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
        tableView.frame = CGRect(x: 5, y: 0, width: view.bounds.width - 10, height: view.bounds.height * 2 / 3)
        tableView.center = view.center
        tableView.isHidden = true
    }
    
    @objc func startWorkoutProcess() {
        // Hide the button
        myButton.isHidden = true
        tableView.isHidden = false
        titleLabel.text = "Choose a nearby gym"
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func checkInToGym(gym: Place) {
        // Show the map
        mapViewContainer.isHidden = false
        
        tableView.isHidden = true
        
        titleLabel.text = "Stay at the gym"
        
        timeLeft = minimumWorkoutTime
        
        let gymLocation = gym.coordinate
        // Center the map at user's current location
        let region = MKCoordinateRegion(center: gymLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        // Add circular overlay to the map
        workoutZoneOverlay = MKCircle(center: gymLocation, radius: workoutRadiusInMeters)
        mapView.addOverlay(workoutZoneOverlay)
        
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
        tableView.isHidden = true
        myButton.isHidden = false
        timeLeft = minimumWorkoutTime
        print("workout complete!")
        titleLabel.text = "Start a workout"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !mapViewContainer.isHidden { return }
        
        guard let location = locations.last else { return }
        
        // Check if at least 5 seconds have passed since the last update
        if let lastUpdate = lastLocationUpdate, Date().timeIntervalSince(lastUpdate) < 5 {
            return  // Less than 5 seconds passed, ignoring this update
        }
        
        spinner.startAnimating()
        
        lastLocationUpdate = Date()  // Update the timestamp
        
        // Now, use the Google Places API to check for nearby gyms
        checkForNearbyGyms(location: location) { isNearby in
            if isNearby {
                print("User is within radius of a relevant location")
            } else {
                print("No relevant locations found within radius.")
            }
            
            DispatchQueue.main.async {
                self.updateUIWithGyms()
                //self.gymCheckButton.isEnabled = isNearby
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
    
    func updateUIWithGyms() {
        if titleLabel.text == "Choose a nearby gym" {
            if places.isEmpty {
                tableView.isHidden = true
                noGymsLabel.isHidden = false  // noGymsLabel is your 'No Gyms' message label
            } else {
                tableView.isHidden = false
                noGymsLabel.isHidden = true
                tableView.reloadData()
            }
        }
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
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locationString)&radius=\(searchRadiusInMeters)&type=\(type)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching places: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.noGymsLabel.isHidden = false
                }
                completion(false)
                return
            }
            
            var newPlaces: [Place] = []
            let group = DispatchGroup()
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    
                    for result in results {
                        if let name = result["name"] as? String,
                           let types = result["types"] as? [String],
                           self.isGym(types),
                           !self.places.contains(where: { $0.name == name }),
                           let geometry = result["geometry"] as? [String: Any],
                           let location = geometry["location"] as? [String: Double],
                           let lat = location["lat"],
                           let lng = location["lng"] {
                            
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                            let photoReference = (result["photos"] as? [[String: Any]])?.first?["photo_reference"] as? String
                            
                            if let photoReference = photoReference {
                                group.enter()
                                self.fetchPhoto(for: photoReference) { fetchedImage in
                                    let newPlace = Place(name: name, types: types, coordinate: coordinate, photoReference: photoReference, image: fetchedImage)
                                    //newPlaces.append(newPlace)
                                    group.leave()
                                }
                            } else {
                                let newPlace = Place(name: name, types: types, coordinate: coordinate, photoReference: nil, image: nil)
                                //newPlaces.append(newPlace)
                            }
                            
                        }
                        
                        print(result)
                    }
                    
                    group.notify(queue: .main) {
                        self.places = newPlaces
                        self.tableView.reloadData()
                        completion(!results.isEmpty)
                    }
    
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("JSON parsing error: \(error)")
                    completion(false)
                }
            }
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                if !self.places.isEmpty {
                    self.tableView.reloadData()
                } else {
                    self.noGymsLabel.isHidden = false
                }
            }
            
        }
        task.resume()
    }
    
    func fetchPhoto(for reference: String, completion: @escaping (UIImage?) -> Void) {
        let photoURLString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=373&photoreference=\(reference)&key=\(Config.getGooglePlacesAPIKey())"
        guard let photoURL = URL(string: photoURLString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: photoURL) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
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
        
        cell.delegate = self
        
        let place = places[indexPath.row]
        cell.configure(with: place)
        
//        if let image = place.image {
//            cell.backgroundImage.image = image
//        }
        
        return cell
    }
    
    func didTapImageView(in cell: PlaceTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let place = places[indexPath.row]
        if place.image != nil {
            let fullScreenVC = FullScreenImageViewController()
            fullScreenVC.modalPresentationStyle = .fullScreen
            fullScreenVC.image = place.image  // Set the image to be displayed
            present(fullScreenVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedGym = places[indexPath.row]  // Assuming gyms is your data source
        presentWorkoutConfirmationAlert(for: selectedGym)
    }
    
    func presentWorkoutConfirmationAlert(for gym: Place) {
        let alert = UIAlertController(title: "Start Workout", message: "Stay around \(gym.name) for at least 20 minutes to complete the workout. Are you ready to start?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { _ in
            self.checkInToGym(gym: gym)
        }))
        present(alert, animated: true)
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


