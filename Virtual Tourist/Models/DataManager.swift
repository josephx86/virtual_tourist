//
//  DataManager.swift
//  Virtual Tourist
//
//  Created by Joseph on 5/26/20.
//  Copyright © 2020 Joseph. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    let persistentContainer: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init() {
        persistentContainer = NSPersistentContainer(name: "Model")
    }
    
    func load(handler: @escaping () -> Void) {
        persistentContainer.loadPersistentStores { (desc, err) in
            handler()
        }
    }
}
