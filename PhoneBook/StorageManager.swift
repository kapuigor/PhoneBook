//
//  StorageManager.swift
//  PhoneBook
//
//  Created by Игорь Капустин on 23.09.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ contact: Contact) {
        
        try! realm.write {
            realm.add(contact)
        }
    }
    
    static func deleteObject(_ contact: Contact) {
        
        try! realm.write {
            realm.delete(contact)
        }
    }
}
