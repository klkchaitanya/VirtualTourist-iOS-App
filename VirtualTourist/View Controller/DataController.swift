//
//  DataController.swift
//  VirtualTourist
//
//  Created by Leela Krishna Chaitanya Koravi on 3/2/21.
//  Copyright © 2021 Leela Krishna Chaitanya Koravi. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (()->Void)? = nil){
        persistentContainer.loadPersistentStores{
            storeDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    
    func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
    
    
    
    func fetchLocation(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let location = (try viewContext.fetch(fr) as! [Pin]).first else {
            return nil
        }
        return location
    }
    
    func fetchAllLocation() throws -> [Pin]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        guard let pin = try viewContext.fetch(fr) as? [Pin] else {
            return nil
        }
        return pin
    }
    
    func fetchAllPhoto(_ predicate: NSPredicate? = nil, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.predicate = predicate
        if let sorting = sorting {
            fr.sortDescriptors = [sorting]
        }
        guard let allPhoto = try viewContext.fetch(fr) as? [Photo] else {
            return nil
        }
        return allPhoto
    }
}
