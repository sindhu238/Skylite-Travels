//
//  LoginVC.swift
//  Skylite Travels
//
//  Created by Venkateswara on 15/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func onLoginPressed(_ sender: UIButton) {
        let email = usernameTF.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = passwordTF.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if email == "" {
            self.alertPopup(title: "Empty fields", message: "Please enter email")
        } else if password == "" {
            self.alertPopup(title: "Empty fields", message: "Please enter password")
        }
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if error != nil {
                self.alertPopup(title: "Login Failed", message: "Please enter correct login credentials")
                
            } else {
                self.performSegue(withIdentifier: "postLoginVC", sender: nil)
            }

        })
    }
    
    @IBAction func onCancelClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onSignupClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signupVC", sender: nil)
    }
    
    func alertPopup(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
        
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
}
