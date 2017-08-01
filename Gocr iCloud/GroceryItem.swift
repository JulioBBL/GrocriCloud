import Foundation
import CloudKit

public struct GroceryItem {
    
    let key: CKRecordID?
    let name: String
    let addedByUser: String
    //let ref: FIRDatabaseReference?
    var completed: Bool
    
    init(name: String, addedByUser: String, completed: Bool) {
        self.key = nil
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
        //self.ref = nil
    }
    
    init(record: CKRecord) {
        self.key = record.recordID
        self.name = String(describing: record.object(forKey: "Value")!)
        self.addedByUser = String(describing: record.creatorUserRecordID!)
        self.completed = (record.object(forKey: "Completed") as! Int).booleanValue
    }
    
    //init(snapshot: FIRDataSnapshot) {
    //    key = snapshot.key
    //    let snapshotValue = snapshot.value as! [String: AnyObject]
    //    name = snapshotValue["name"] as! String
    //    addedByUser = snapshotValue["addedByUser"] as! String
    //    completed = snapshotValue["completed"] as! Bool
    //    ref = snapshot.ref
    //}
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "addedByUser": addedByUser,
            "completed": completed
        ]
    }
    
}

extension Int {
    var booleanValue: Bool {
        if self == 0 {
            return false
        } else {
            return true
        }
    }
}
