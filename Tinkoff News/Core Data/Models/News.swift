//
//  News.swift
//  Tinkoff News
//
//  Created by Sergey Korobin on 30.12.17.
//  Copyright © 2017 SergeyKorobin. All rights reserved.
//

import Foundation
import CoreData


extension News {
    static func insertNews(in context: NSManagedObjectContext, with id: Int) -> News? {
        if let news = NSEntityDescription.insertNewObject(forEntityName: "News", into: context) as? News {
            news.id = Int32(id)
            
            return news
        }
        return nil
    }
    
    static func findOrInsertNews(in context: NSManagedObjectContext, with id: Int) -> News? {
        guard let _ = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var news: News?
        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let foundNews = results.first {
                news = foundNews
            }
        } catch let error as NSError {
            print("An error is fired: \(error.localizedDescription)")
        }
        
        if news == nil {
            news = News.insertNews(in: context, with: id)
        }
        
        return news
    }
    
    static func findNews(in context: NSManagedObjectContext) -> [News?] {
        
        var newsMass: [News?] = []
        let fetchRequest: NSFetchRequest<News> = News.fetchRequest()
        let sectionSortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        
        do {
            let results = try context.fetch(fetchRequest)
            print(results.count)
            newsMass = results

        } catch let error as NSError {
            print("An error is fired: \(error.localizedDescription)")
        }
        
        return newsMass
    }
}

