//
//  ViewController.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/29/23.
//

import GooglePlaces
import UIKit

class ViewController : UIViewController, CLLocationManagerDelegate {
    
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    
    private var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
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
            
            // Check if the types include "gym"
            if place.types?.contains("gym") ?? false {
                // The place is a gym
                strongSelf.nameLabel.text = place.name
                strongSelf.addressLabel.text = place.formattedAddress
                // Handle the logic for the user being at a gym
            } else {
                // The place is not a gym
                strongSelf.nameLabel.text = "Not a gym"
                strongSelf.addressLabel.text = place.formattedAddress
                // Handle accordingly
            }
            
        }
    }
}


