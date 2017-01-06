//
//  QuoteVC.swift
//  Skylite Travels
//
//  Created by Venkateswara on 06/01/17.
//  Copyright © 2017 Sindhu. All rights reserved.
//

import UIKit

class QuoteVC: UIViewController {

    @IBOutlet weak var fromTV: UILabel!
    @IBOutlet weak var toTV: UILabel!
    @IBOutlet weak var dateTV: UILabel!
    @IBOutlet weak var passLugTV: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    var from: String!
    var to: String!
    var date: String!
    var passLug: String!
    var amt: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromTV.text = from
        toTV.text = to
        dateTV.text = date
        passLugTV.text = passLug
        amount.text = amt
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var onBookNowClicked: UIButton!
}
