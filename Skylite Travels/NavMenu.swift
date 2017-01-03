//
//  NavMenu.swift
//  Skylite Travels
//
//  Created by Venkateswara on 20/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import UIKit
import Firebase

class NavMenu: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func onBookingPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onBookingHistoryPressed(_ sender: UIButton) {
    }
   
    @IBAction func onContactUsPressed(_ sender: UIButton) {
    }
    
}
