//
//  Users.swift
//  Skylite Travels
//
//  Created by Venkateswara on 20/12/16.
//  Copyright © 2016 Sindhu. All rights reserved.
//

import Foundation

class Users {
    private var _firstname: String
    private var _lastname: String
    private var _email: String
    private var _phonenumber: String
    private var _uid: String
    
    var firstname: String {
        return _firstname
    }
    
    var lastname: String {
        return _lastname
    }
    
    var email: String {
        return _email
    }
    
    var phonenumber: String {
        return _phonenumber
    }
    
    var uid: String {
        return _uid
    }
    
    init(user: Dictionary<String, String>) {
        self._firstname = user["First Name"]!
        self._lastname = user["Last name"]!
        self._email = user["Email"]!
        self._phonenumber = user["Phone Number"]!
        self._uid = user["Userid"]!
    }
}
