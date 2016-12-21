//
//  NavMenu.swift
//  Skylite Travels
//
//  Created by Venkateswara on 20/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import UIKit

class NavMenu: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.barTintColor = UIColor.brown
        let view = UIView(frame:
            CGRect(x: 12.0, y: 230.0, width: UIScreen.main.bounds.size.width, height: 20.0)
        )
        view.backgroundColor = UIColor.orange
        
        self.view.addSubview(view)
        UINavigationBar.appearance().barTintColor = UIColor.blue
    }

   
}
