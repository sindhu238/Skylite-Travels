//
//  Places.swift
//  Skylite Travels
//
//  Created by Venkateswara on 22/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import Foundation
import UIKit

class Places {
    var _placeName: String
    var _address: String
    var _latitude: Double
    var _longitude: Double
    var _category: String
    var _zipcode: String
    
    var placeName: String {
        return _placeName
    }
    var address: String {
        return _address
    }
    var latitude: Double {
        return _latitude
    }
    var longitude: Double {
        return _longitude
    }
    var category: String {
        return _category
    }
    var zipcode: String {
        return _zipcode
    }
    
    init(placeName: String, address: String, latitude: Double, longitude: Double, category: String, zipcode: String) {
        _placeName = placeName
        _address = address
        _latitude = latitude
        _longitude = longitude
        _category = category
        _zipcode = zipcode
    }
}
