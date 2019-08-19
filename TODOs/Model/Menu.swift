//
//  MenuModel.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import CoreData

class Menu {
    let lists: NSFetchedResultsController<List>
    let tags: NSFetchedResultsController<Tag>
    
    init() {
        
        lists = {
            let request: NSFetchRequest<List> = NSFetchRequest(entityName: "List")
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            return NSFetchedResultsController(fetchRequest: request,
                                              managedObjectContext: AppDelegate.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        }()
        tags = {
            let request: NSFetchRequest<Tag> = NSFetchRequest(entityName: "Tag")
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return NSFetchedResultsController(fetchRequest: request,
                                              managedObjectContext: AppDelegate.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        }()
    }
    
    func createNewList(title: String? = nil, todos: NSSet? = nil) -> List {
        let newList = List(entity: NSEntityDescription.entity(forEntityName: "List",
                                                              in: AppDelegate.viewContext)!,
                           insertInto: AppDelegate.viewContext)
        if let title = title { newList.title = title }
        if let todos = todos { newList.todos = todos }
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
        
        return newList
    }
    
    func remove(_ list: List) {
        AppDelegate.viewContext.delete(list)
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func todosFor(tag: Tag) -> NSFetchedResultsController<Todo> {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = NSPredicate(format: "ANY tags.name = %@", tag.name!)
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: AppDelegate.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
}
