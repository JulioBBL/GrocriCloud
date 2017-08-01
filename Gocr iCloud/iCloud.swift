//
//  iCloud.swift
//  Grocr iCloud
//
//  Created by Julio Brazil on 24/07/17.
//  Copyright © 2017 Julio Brazil LTDA. All rights reserved.
//

import Foundation
import CloudKit

public class Icloud {
    static let sharedInstance = Icloud()
    
    let container: CKContainer
    let publicDB: CKDatabase
    
    private init() {
        self.container = CKContainer.default()
        self.publicDB = container.publicCloudDatabase
    }
    
    public func getData(completion: @escaping ([GroceryItem]) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Item", predicate: predicate)
        var itens: [GroceryItem] = []
        
        self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if (records?.count)! > 0 {
                for record in records! {
                    itens.append(GroceryItem(record: (record)))
                }
                completion(itens)
            }
        }
    }
    
    public func saveData(item: GroceryItem, completion: @escaping () -> Void) {
        let data = CKRecord(recordType: "Item")
        data.setValue(item.name, forKey: "Value")
        data.setValue(item.completed, forKey: "Completed")
        
        self.publicDB.save(data) { (record, errod) in
            print("saved \(item.name) to iCloud")
            completion()
        }
    }
    
    public func updateData(item: GroceryItem, completion: @escaping (Error?) -> Void) {
        let data = CKRecord(recordType: "Item")
        data.setValue(item.name, forKey: "Value")
        data.setValue(item.completed, forKey: "Completed")
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [data], recordIDsToDelete: [item.key!])
        modifyOperation.savePolicy = .ifServerRecordUnchanged
        
        self.publicDB.add(modifyOperation)
    }
    
    public func deleteData(item: GroceryItem, completion: @escaping (Error?) -> Void) {
        self.publicDB.delete(withRecordID: item.key!) { (record, error) in
            completion(error)
        }
    }
}
