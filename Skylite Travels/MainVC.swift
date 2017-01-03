//
//  MainVC.swift
//  Skylite Travels
//
//  Created by Venkateswara on 15/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onLoginClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "loginVC", sender: nil)
    }
    
    @IBAction func onGetQuoteClicked(_ sender: UIButton) {
    }
    

}
