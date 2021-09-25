//
//  ContactModel.swift
//  PhoneBook
//
//  Created by Игорь Капустин on 21.09.2021.
//

import RealmSwift

class Contact: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var secondName = ""
    @objc dynamic var dateOfBirth: String?
    @objc dynamic var company: String?
    @objc dynamic var email: String?
    @objc dynamic var phoneNumber: String?
    
    convenience init (name: String, secondName: String, dateOfBirth: String?, company: String?, email: String?, phoneNumber: String?) {
        self.init()
        self.name = name
        self.secondName = secondName
        self.dateOfBirth = dateOfBirth
        self.company = company
        self.email = email
        self.phoneNumber = phoneNumber
    }
}


