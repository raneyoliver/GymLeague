//
//  Config.swift
//  GymLeague
//
//  Created by Oliver Raney on 12/29/23.
//

import Foundation

class Config {
    private static func valueForAPIKey(named keyname: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: "keys", ofType: "plist") else {
            fatalError("Couldn't find file 'keys.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        let value = plist?.object(forKey: keyname) as? String
        return value
    }

    static func getGooglePlacesAPIKey() -> String {
        guard let key = valueForAPIKey(named: "GooglePlacesAPIKey") else {
            fatalError("Couldn't find key 'GooglePlacesAPIKey' in 'Keys.plist'.")
        }
        return key
    }
}

