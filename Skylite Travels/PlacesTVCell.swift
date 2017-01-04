//
//  placesTVCell.swift
//  Skylite Travels
//
//  Created by Venkateswara on 22/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import UIKit

class PlacesTVCell: UITableViewCell {

    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var placeAddress: UILabel!
   
    func configure(places: Places) {
        placeName.text = places.placeName
        placeAddress.text = places.address
    }

}
