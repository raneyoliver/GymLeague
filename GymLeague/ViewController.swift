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
    var image: UIImage?
    let backgroundColor: UIColor
    let distance: Double?
    let isGym: Bool
    let isRouteCityOrOther: Bool
    var whitelistStatus: String
}

class ViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, PlaceTableViewCellDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noGymsLabel: UILabel!
    @IBOutlet weak var startWorkoutButton: UIButton!
    @IBOutlet weak var cancelWorkoutButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var countdownView: UIView!
    var digitLabels = [UILabel]()

    @IBOutlet weak var countdownAndCancelView: UIView!
    let gymCheckButton = UIButton() // Create a button
    
    var myButton = GymButton()
    
    private var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    var db: Firestore!
    
    var location: CLLocation!
    var lastLocationUpdate: Date?

    var mapView: MKMapView!
    var mapViewContainer: UIView!
    var currentCircle: MKCircle?

    private let refreshControl = UIRefreshControl()
    var tableView: UITableView!
    var places = [Place]()
    
    let spinner = UIActivityIndicatorView(style: .large)
    
    var workoutZoneOverlay: MKCircle!
    var countdownTimer: Timer!
    
    let minimumWorkoutTime = 10 //20 * 60 // 20 minutes in seconds
    var timeLeft:Int!
    let workoutRadiusInMeters:Double = 100
    let searchRadiusInMeters:Double = 50
    
    let gymTypes = ["gym"]
    let nonGymTypes = ["route", "locality", "political", "country", "administrative_area_level_1", "administrative_area_level_2", "administrative_area_level_3", "parking", "grocery_or_supermarket", "airport", "bus_station", "train_station", "transit_station", "subway_station", "natural_feature", "store", "supermarket", "shopping_mall", "restaurant", "cafe", "food", "clothing_store", "book_store", "furniture_store", "lodging", "hotel", "park", "campground", "zoo", "aquarium", "cemetery", "funeral_home", "library", "museum", "art_gallery", "church", "mosque", "synagogue"]
    
    var selectedGym:Place!

    
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
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        db = Firestore.firestore()
        
        noGymsLabel.isHidden = true
        cancelWorkoutButton.isHidden = true
        countdownAndCancelView.isHidden = true
        
        setupTableView()
        setupSegmentedControl()
        setupMapContainerView()
        setupSpinner()
        setupCountdownView()
        
        titleLabel.text = "Start a workout"

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        startWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        cancelWorkoutButton.translatesAutoresizingMaskIntoConstraints = false
        countdownAndCancelView.translatesAutoresizingMaskIntoConstraints = false
        
        let distance = tabBarController!.tabBar.frame.minY - tableView.frame.maxY
        NSLayoutConstraint.activate([
            startWorkoutButton.centerYAnchor.constraint(equalTo: tableView.bottomAnchor, constant: distance / 2),
            countdownAndCancelView.centerYAnchor.constraint(equalTo: tableView.bottomAnchor, constant: distance / 2),
        ])

    }

    
    func updateStartWorkoutButtonState() {
        DispatchQueue.main.async {
            if self.selectedGym != nil {
                self.startWorkoutButton.setTitle("Start Workout", for: .normal)
                self.startWorkoutButton.isEnabled = true
            } else {
                self.startWorkoutButton.setTitle("Select a gym", for: .normal)
                self.startWorkoutButton.isEnabled = false
            }
        }
    }

    
    @IBAction func startWorkoutButtonPressed(_ sender: Any) {
        presentWorkoutConfirmationAlert(for: selectedGym)
    }
    
    @IBAction func cancelWorkoutButtonPressed(_ sender: Any) {
        presentCancelWorkoutConfirmationAlert()
    }

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData() // Reload the table view data whenever the segment changes
        updateUIWithGyms()
    }
    
    func setupSpinner() {
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noGymsLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: noGymsLabel.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: noGymsLabel.centerYAnchor)
        ])
        view.bringSubviewToFront(noGymsLabel)
    }
    
    func setupCountdownView() {
        let width: CGFloat = 150
        let countdownHeight: CGFloat = 40
        countdownView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //countdownView.bottomAnchor.constraint(equalTo: mapViewContainer.topAnchor, constant: -8),
            countdownView.heightAnchor.constraint(equalToConstant: countdownHeight),
            countdownView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownView.widthAnchor.constraint(equalToConstant: width)
        ])
        countdownView.backgroundColor = CustomBackgroundView.color
        countdownView.layer.cornerRadius = 8
        countdownView.clipsToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 2 // Adjust the spacing as needed

        countdownView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: countdownView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: countdownView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: countdownView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: countdownView.trailingAnchor)
        ])

        
        let characters = ["0", "0", ":", "0", "0"]
        for char in characters {
            let label = UILabel()
            label.text = char
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 30, weight: .bold)
            label.textAlignment = .center
            label.backgroundColor = UIColor.black.withAlphaComponent(0.15) // Set individual background color here
            label.layer.cornerRadius = 4
            label.clipsToBounds = true
            stackView.addArrangedSubview(label)

//
//            // Add constraints or set frame
//            label.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                label.widthAnchor.constraint(equalToConstant: 20),
//                label.heightAnchor.constraint(equalTo: countdownView.heightAnchor),
//                label.centerYAnchor.constraint(equalTo: countdownView.centerYAnchor),
//                // Adjust horizontal positioning based on index
//            ])
//
            digitLabels.append(label)
        }
        
        NSLayoutConstraint.activate([
            countdownAndCancelView.widthAnchor.constraint(equalToConstant: width),
            countdownAndCancelView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownAndCancelView.heightAnchor.constraint(equalToConstant: countdownHeight + cancelWorkoutButton.frame.height + 8),
            cancelWorkoutButton.topAnchor.constraint(equalTo: countdownView.bottomAnchor, constant: 8),
        ])
        
        countdownAndCancelView.backgroundColor = CustomBackgroundView.color
    }
    
    func setupSegmentedControl() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -8),
            segmentedControl.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
        ])
    }
    
    func setupMapContainerView() {
        mapViewContainer = UIView() // Adjust frame as needed
        //mapViewContainer.translatesAutoresizingMaskIntoConstraints = false
        mapViewContainer.frame = tableView.frame
        mapViewContainer.backgroundColor = .lightGray // So you can see the container
        mapViewContainer.isHidden = true
        mapViewContainer.layer.cornerRadius = 8
        mapViewContainer.clipsToBounds = true
        //mapViewContainer.center = view.center
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
        tableView.backgroundColor = CustomBackgroundView.oneAboveColor
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
        
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "PlaceCell")

        view.addSubview(tableView)
        
        // Set tableView frame or constraints here
        // Example frame setup
        let tabBarHeight:CGFloat = 41.5
        tableView.frame = CGRect(x: 5, y: (view.bounds.height / 4) - tabBarHeight, width: view.bounds.width - 10, height: view.bounds.height / 2)
        //tableView.center = view.center
        tableView.isHidden = false
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshPlacesData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Scroll up to refresh")
    }
    
    @objc private func refreshPlacesData(_ sender: Any) {
        // Perform the re-search here
        guard let location = self.location else { return }
        isTypeNearby(location: location, type: nil) { success in
            // Handle the result of the unfiltered search
            DispatchQueue.main.async {
                // Update the UI accordingly
                self.updateUIWithGyms()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func showUnverifiedGymAlert(for gym: Place, viewController: UIViewController, onWhitelistRequest: @escaping () -> Void) {
        let alert = UIAlertController(title: "Unverified Gym", message: "The gym you've selected, '\(gym.name)', is not a verified gym. Would you like to continue and send a request to whitelist this place as a gym?", preferredStyle: .alert)

        let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
            onWhitelistRequest()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(continueAction)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true)
    }

    func checkInToGym(gym: Place, viewController: UIViewController) {
        if !gym.isGym, gym.whitelistStatus == "none" {
            showUnverifiedGymAlert(for: gym, viewController: viewController) {
                // Logic to handle the gym whitelisting request
                FirestoreService.shared.storeWhitelistRequest(for: gym) { success, error in
                    if let error = error {
                        print("Error storing whitelist request: \(error)")
                    } else if success {
                        print("Whitelist request stored successfully.")
                    } else {
                        print("Duplicate request found. Not stored.")
                    }
                }
                self.continueCheckIn(gym: gym)
            }
        } else {
            continueCheckIn(gym: gym)
        }
    }
    
    func continueCheckIn(gym: Place) {
        // Show the map
        mapViewContainer.isHidden = false
        tableView.isHidden = true
        startWorkoutButton.isHidden = true
        noGymsLabel.isHidden = true
        cancelWorkoutButton.isHidden = false
        segmentedControl.isHidden = true
        countdownAndCancelView.isHidden = false
        
        titleLabel.text = "Stay at the gym"
        
        timeLeft = minimumWorkoutTime
        updateTimeLeftLabel()
        
        let gymLocation = gym.coordinate
        // Center the map at user's current location
        let region = MKCoordinateRegion(center: gymLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        // Remove the existing circle if it exists
        if let existingCircle = currentCircle {
            mapView.removeOverlay(existingCircle)
        }
        
        // Add circular overlay to the map
        workoutZoneOverlay = MKCircle(center: gymLocation, radius: workoutRadiusInMeters)
        mapView.addOverlay(workoutZoneOverlay)
        currentCircle = workoutZoneOverlay
        
        // Start the countdown timer
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if timeLeft > 0 {
            timeLeft -= 1
            // Update your label or annotation on the map with the remaining time
            DispatchQueue.main.async {
                self.updateMapAnnotationWithTime()
                self.updateTimeLeftLabel()
            }
            
        } else {
            countdownTimer.invalidate()
            // Handle completion of the 20-minute period
            handleWorkoutCompletion()
        }
    }

    func updateTimeLeftLabel() {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60

        digitLabels[0].text = "\(minutes / 10)"
        digitLabels[1].text = "\(minutes % 10)"
        digitLabels[3].text = "\(seconds / 10)"
        digitLabels[4].text = "\(seconds % 10)"
            
//        let minutes = timeLeft / 60
//        timeLeftLabel.text = "Stay within the circle for \(minutes > 0 ? "\(minutes) minutes and " : "")\(timeLeft % 60) seconds!"
    }
    
    func updateMapAnnotationWithTime() {
        let userAnnotation = MKPointAnnotation()
        userAnnotation.coordinate = location.coordinate
        userAnnotation.title = "Your Location"

        // Remove old annotation and add new one
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(userAnnotation)
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
        DispatchQueue.main.async {
            self.mapViewContainer.isHidden = true
            self.tableView.isHidden = false
            self.startWorkoutButton.isHidden = false
            self.cancelWorkoutButton.isHidden = true
            self.segmentedControl.isHidden = false
            self.countdownAndCancelView.isHidden = true
            self.titleLabel.text = "Start a workout"
            self.tableView.reloadData()
            self.selectedGym = nil
            self.updateStartWorkoutButtonState()
        }
        
        timeLeft = minimumWorkoutTime
        print("workout complete!")
        
        PointsService.shared.awardPoints(forUserID: UserData.shared.userID!) { success in
            if success {
                print("points awarded succesfully")
                self.addCompletedWorkout(for: UserData.shared.userID!, username: UserData.shared.username!, newPoints: UserData.shared.points!)
            } else {
                print("could not award points")
            }
        }
    }
    
    func addCompletedWorkout(for userId: String, username: String, newPoints: Double) {
        // Prepare data
        let workoutData: [String: Any] = [
            "userId": userId,
            "username": username,
            "points": newPoints,
            "date": Int(Date().timeIntervalSince1970) // Current date as Unix timestamp
        ]

        // Add a new document to the completed_workouts collection
        db.collection("completed_workouts").addDocument(data: workoutData) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        
    
        if !mapViewContainer.isHidden {
            let gymCoordinate = CLLocation(latitude: selectedGym.coordinate.latitude, longitude: selectedGym.coordinate.longitude)
            let distance = location.distance(from: gymCoordinate)
            if distance > workoutRadiusInMeters {
                cancelWorkout()
            }
        }
        
        // Check if at least 5 seconds have passed since the last update
        if let lastUpdate = lastLocationUpdate, Date().timeIntervalSince(lastUpdate) < 5 {
            return  // Less than 5 seconds passed, ignoring this update
        }
        
        spinner.startAnimating()
        
        lastLocationUpdate = Date()  // Update the timestamp
        
        // Now, use the Google Places API to check for nearby gyms
        isTypeNearby(location: location, type: nil) { success in
            // Handle the result of the unfiltered search
            DispatchQueue.main.async {
                // Update the UI accordingly
                self.updateUIWithGyms()
            }
        }
    }

    func updateUIWithGyms() {
        if titleLabel.text == "Start a workout" {
            updateStartWorkoutButtonState()
            
            if tableView.numberOfRows(inSection: 0) == 0 {
                //tableView.isHidden = true
                noGymsLabel.isHidden = false  // noGymsLabel is your 'No Gyms' message label
                startWorkoutButton.isEnabled = false
            } else {
                //tableView.isHidden = false
                noGymsLabel.isHidden = true
                //tableView.reloadData()
                startWorkoutButton.isEnabled = true
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
    
    func isTypeNearby(location: CLLocation, type: String?, completion: @escaping (Bool) -> Void) {
        let locationString = locationString(from: location)
        
        let apiKey = Config.getGooglePlacesAPIKey()
        
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(locationString)&radius=\(searchRadiusInMeters)&key=\(apiKey)"
        if let type = type {
            urlString += "&type=\(type)"
        }
        
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
                           !self.places.contains(where: { $0.name == name }),
                           let geometry = result["geometry"] as? [String: Any],
                           let location = geometry["location"] as? [String: Double],
                           let lat = location["lat"],
                           let lng = location["lng"] {
                            
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                            let photoReference = (result["photos"] as? [[String: Any]])?.first?["photo_reference"] as? String
                            let backgroundColor = CustomBackgroundView.randomColor()
                            let toLocation = CLLocation(latitude: lat, longitude: lng)
                            let distance = self.calculateDistance(fromLocation: self.location, toLocation: toLocation)
                            let isRouteCityOrOther = self.isRouteCityOrOther(types)
                        
                            group.enter()
                            self.isGym(name: name, coordinate: coordinate, types: types) { isGym in
                                // Check if the place has a whitelist request
                                group.enter()
                                FirestoreService.shared.checkWhitelistStatus(for: Place(name: name, types: types, coordinate: coordinate, photoReference: photoReference, image: nil, backgroundColor: backgroundColor, distance: distance, isGym: isGym, isRouteCityOrOther: isRouteCityOrOther, whitelistStatus: "")) { whitelistStatus in
                                    
                                    
                            
                                    var newPlace = Place(name: name, types: types, coordinate: coordinate, photoReference: photoReference, image: nil, backgroundColor: backgroundColor, distance: distance, isGym: isGym, isRouteCityOrOther: isRouteCityOrOther, whitelistStatus: whitelistStatus)
                                    
                                    if let photoReference = photoReference {
                                        self.fetchPhoto(for: photoReference) { fetchedImage in
                                            newPlace.image = fetchedImage
                                            DispatchQueue.main.async {
                                                newPlaces.append(newPlace)
                                                group.leave()
                                            }
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            newPlaces.append(newPlace)
                                            group.leave()
                                        }
                                    }
                                    group.leave() // Leave the group for the whitelist check
                                }
                            }
                        }
                        
                        
                    }
                    
                    group.notify(queue: .main) {
                        newPlaces = newPlaces.sorted {$0.distance! < $1.distance!}
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
    
    func calculateDistance(fromLocation: CLLocation, toLocation: CLLocation) -> Double {
        let distanceInMeters = fromLocation.distance(from: toLocation)
        let distanceInMiles = distanceInMeters / 1609.34  // meters to miles

        return distanceInMiles
    }

    
    func fetchPhoto(for reference: String, completion: @escaping (UIImage?) -> Void) {
        let photoURLString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=\(reference)&key=\(Config.getGooglePlacesAPIKey())"
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

    
    func isGym(name: String, coordinate: CLLocationCoordinate2D, types: [String], completion: @escaping (Bool) -> Void) {
        let gym = Place(name: name, types: types, coordinate: coordinate, photoReference: nil, backgroundColor: UIColor(), distance: nil, isGym: false, isRouteCityOrOther: false, whitelistStatus: "")
        
        FirestoreService.shared.checkWhitelistStatus(for: gym) { whitelistStatus in
            if whitelistStatus == "whitelisted" {
                print("The gym is whitelisted.")
                completion(true)
            } else {
                print("The gym is not whitelisted.")
                completion(types.contains(where: self.gymTypes.contains))
            }
        }
    }
    
    func isRouteCityOrOther(_ types: [String]) -> Bool {
        return types.contains(where: nonGymTypes.contains)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Filter segment
            return places.filter { place in
                place.isGym
            }.count
        default: // All segment
            return places.filter { place in
                !place.isRouteCityOrOther
            }.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceTableViewCell else {
            fatalError("Could not dequeue PlaceTableViewCell")
        }
        
        let place: Place
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Filter segment
            place = places.filter { place in
                place.isGym
            }[indexPath.row]
        default: // All segment
            place = places.filter { place in
                !place.isRouteCityOrOther
            }[indexPath.row]
        }
        
        cell.delegate = self
        
        //let place = places[indexPath.row]
        cell.configure(with: place, location: location)
        
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
        selectedGym = places[indexPath.row]  // Assuming gyms is your data source
        DispatchQueue.main.async {
            self.updateStartWorkoutButtonState()
        }
    }
    
    func presentWorkoutConfirmationAlert(for gym: Place) {
        let alert = UIAlertController(title: "Start Workout", message: "Stay around \(gym.name) for at least 20 minutes to complete the workout. Are you ready to start?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Start", style: .default, handler: { _ in
            self.checkInToGym(gym: gym, viewController: self)
        }))
        present(alert, animated: true)
    }
    
    func presentCancelWorkoutConfirmationAlert() {
        let alert = UIAlertController(title: "Cancel Workout", message: "You will not receive any points. Are you sure you want to cancel this workout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.cancelWorkout()
        }))
        present(alert, animated: true)
    }
    
    func cancelWorkout () {
        DispatchQueue.main.async {
            self.mapViewContainer.isHidden = true
            self.tableView.isHidden = false
            self.startWorkoutButton.isHidden = false
            self.cancelWorkoutButton.isHidden = true
            self.segmentedControl.isHidden = false
            self.titleLabel.text = "Start a workout"
            self.tableView.reloadData()
            self.selectedGym = nil
            self.countdownAndCancelView.isHidden = true
            self.updateStartWorkoutButtonState()
        }
        
        countdownTimer.invalidate()
        timeLeft = minimumWorkoutTime
        print("workout canceled by user")
    }
    
}


