//
//  SignupVC.swift
//  Skylite Travels
//
//  Created by Venkateswara on 19/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import UIKit
import EasyToast
import Firebase


class SignupVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var phoneNo: UITextField!
    @IBOutlet weak var conPassword: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var scrollview: UIScrollView!
    
    var selectedTF: UITextField!
    var databaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstName.delegate = self
        self.lastname.delegate = self
        self.email.delegate = self
        self.password.delegate = self
        self.conPassword.delegate = self
        self.phoneNo.delegate = self
        self.databaseRef = FIRDatabase.database().reference()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTF = textField
        print("text field \(selectedTF.frame.origin.y)")
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardIsShown), name: Notification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
//
    func keyboardIsShown(notification: Notification) {
//        let keyboardSize: CGSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect).size
//        let offset: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect).size
//        
//        if keyboardSize.height == offset.height {
//            if self.view.frame.origin.y == 0 {
//                UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                    self.view.frame.origin.y -= keyboardSize.height
//                })
//            }
//        } else {
//            UIView.animate(withDuration: 0.1, animations: { () -> Void in
//                self.view.frame.origin.y += keyboardSize.height - offset.height
//            })
//        }
//        print(self.view.frame.origin.y)
        self.adjustInsetForKeyboardShow(show: true, notification: notification as NSNotification)

        
        
    }

    func keyboardWillHide(notification: Notification) {
        adjustInsetForKeyboardShow(show: false, notification: notification as NSNotification)

    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        print("key \(keyboardFrame.origin.y)")
        if let textfield = selectedTF {
            print("yes1")
            if (textfield.frame.origin.y) > keyboardFrame.origin.y {
                print("yes2")

                let moveBy = (textfield.frame.origin.y) - keyboardFrame.origin.y
                let adjustmentHeight = moveBy * (show ? 1 : -1)
                print(" height \(moveBy) \(adjustmentHeight)")
                scrollview.contentInset.bottom += adjustmentHeight
                print("scrollview \(scrollview.contentInset.bottom)")

                scrollview.scrollIndicatorInsets.bottom += adjustmentHeight
                
            }
        }
        
//        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
//        scrollview.contentInset.bottom += adjustmentHeight
//        scrollview.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    
    @IBAction func onRegisterClicked(_ sender: UIButton) {
        // Textfield Validations
        if firstName.text == "" {
            self.popAlert(title: "Empty Fields", message: "Please enter firstname")
        } else if lastname.text == "" {
            self.popAlert(title: "Empty Fields", message: "Please enter lastname")
        } else if email.text == "" {
            self.popAlert(title: "Empty Fields", message: "Please enter email")
        } else if password.text == "" {
            self.popAlert(title: "Empty Fields", message: "Please enter password")
        } else if (password.text?.characters.count)! < 6 {
            self.popAlert(title: "Too short password", message: "The password must be 6 characters long or more")
        }
        else if conPassword.text == "" {
            self.popAlert(title: "Empty Fields", message: "Please enter confirm password")
        } else if phoneNo.text == "" {
            self.popAlert(title: "Empty Fields", message: "Please enter phone number")
        } else if password.text != conPassword.text {
            self.popAlert(title: "Passwords doesn't match", message: "Please check your passwords and enter again")
            password.text = ""
            conPassword.text = ""
        } else {
            // Remove all whitespaces at the ned
            let emailTemp = email.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            let passwordTemp = password.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            let fnTemp = firstName.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            let lnTemp = lastname.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            let phnoTemp = phoneNo.text?.trimmingCharacters(in: CharacterSet.whitespaces)
            
            // Create new user
            FIRAuth.auth()?.createUser(withEmail: emailTemp!, password: passwordTemp!, completion: { (user, error) in
                // If there is no error in creation
                if error == nil {
                    print("userid \(user?.uid)!")
                    let userCreated : Dictionary<String,String> = ["First Name": fnTemp!,
                                                                   "Last Name": lnTemp!,
                                                                   "Email": emailTemp!,
                                                                   "Phone Number": phnoTemp!,
                                                                   "Userid": (user?.uid)!]
                    self.performSegue(withIdentifier: "postloginVC", sender: nil)
                    self.view.showToast("Signup successful", position: .bottom, popTime: 5, dismissOnTap: false)
                    let currentuser = self.databaseRef.child("users").child((user?.uid)!)
                    currentuser.setValue(userCreated)
                    print("created new : \(userCreated["Userid"])")
                }
                // if there is some error
                else {
                    print("signup error \(error?.localizedDescription)")
                    if (error?.localizedDescription)!.contains("The email address is badly formatted.")
                    {
                        self.popAlert(title: "The email address is badly formatted", message: "")
                    } else if (error?.localizedDescription)!.contains("The email address is already in use by another account.") {
                        self.popAlert(title: "The email address is already in use by another account", message: "")
                    } else {
                        print("signup \(error?.localizedDescription)")
                    }
                }
                
            })
        }
    }
    
    @IBAction func onBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func popAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel) { (result: UIAlertAction) -> Void in
        
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

}
