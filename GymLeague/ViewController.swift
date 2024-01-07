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

class ViewController : UIViewController, CLLocationManagerDelegate {
    
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    
    @IBOutlet weak var typesLabel: UILabel!
    private var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    var db: Firestore!

    var currentAddress:String!
    var isGym:Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        db = Firestore.firestore()

    }
    
    // Add a UIButton in Interface Builder, and connect the action to this function.
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .types]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "")")
                return
            }
            
            guard let place = placeLikelihoods?.first?.place else {
                strongSelf.nameLabel.text = "No current place"
                strongSelf.addressLabel.text = ""
                return
            }
            
            strongSelf.currentAddress = place.name
            strongSelf.isGym = place.types!.contains("gym") || place.types!.contains("point_of_interest") || place.types!.contains("establishment")
            
            // Check if the types include "gym"
            if place.types?.contains("gym") ?? false {
                // The place is a gym
                strongSelf.nameLabel.text = place.name
                strongSelf.addressLabel.text = place.formattedAddress
                strongSelf.typesLabel.text = place.types?.joined(separator: "\n")
                // Handle the logic for the user being at a gym
            } else {
                // The place is not a gym
                strongSelf.nameLabel.text = "Not a gym"
                strongSelf.addressLabel.text = place.formattedAddress
                strongSelf.typesLabel.text = place.types?.joined(separator: "\n")
                // Handle accordingly
            }
            
        }

    }
    
    

}


