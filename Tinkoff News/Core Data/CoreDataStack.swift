//
//  CoreDataStack.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 30.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation

import Foundation
import CoreData

class CoreDataStack: NSObject {
    private var storeURL : URL {
        get {
            let documentDirURL : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let url = documentDirURL.appendingPathComponent("Store.sqlite")
            return url
        }
    }
    
    private let managedObjectModelName = "Tinkoff_News"
    private var _managedObjectModel : NSManagedObjectModel?
    private var managedObjectModel : NSManagedObjectModel? {
        get {
            if _managedObjectModel == nil {
                guard let modelURL = Bundle.main.url(forResource: managedObjectModelName, withExtension: "momd") else {
                    print("Empty model url!")
                    return nil
                }
                
                _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            }
            
            return _managedObjectModel
        }
    }
    
    private var _persistentStoreCoordinator : NSPersistentStoreCoordinator?
    private var persistentStoreCoordinator : NSPersistentStoreCoordinator? {
        get {
            if _persistentStoreCoordinator == nil {
                guard let model = managedObjectModel else {
                    print("Empty managed object model!")
                    return nil
                }
                
                _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                do {
                    try _persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                } catch {
                    assert(false, "Error adding persistent store to coordinator: \(error)")
                }
            }
            
            return _persistentStoreCoordinator
        }
    }
    
    private var _masterContext : NSManagedObjectContext?
    private var masterContext : NSManagedObjectContext? {
        get {
            if _masterContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                
                guard let persistentStoreCoordinator = persistentStoreCoordinator else {
                    print("Empty persistent store coordinator!")
                    return nil
                }
                
                context.persistentStoreCoordinator = persistentStoreCoordinator
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _masterContext = context
            }
            
            return _masterContext
        }
    }
    
    private var _mainContext : NSManagedObjectContext?
    public var mainContext : NSManagedObjectContext? {
        get {
            if _mainContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                
                guard let parentContext = masterContext else {
                    print("No master context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _mainContext = context
            }
            
            return _mainContext
        }
    }
    
    private var _saveContext : NSManagedObjectContext?
    public var saveContext : NSManagedObjectContext? {
        get {
            if _saveContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                
                guard let parentContext = mainContext else {
                    print("No main context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _saveContext = context
            }
            
            return _saveContext
        }
    }
    
    public func performSave(context: NSManagedObjectContext, completionHandler: (()->Void)?) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                } catch {
                    print("Context save error: \(error)")
                }
                
                if let parent = context.parent {
                    self?.performSave(context: parent, completionHandler: completionHandler)
                } else {
                    completionHandler?()
                }
            }
        } else {
            completionHandler?()
        }
    }
}
