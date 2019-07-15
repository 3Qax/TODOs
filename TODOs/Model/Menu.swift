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
    private(set) var lists: NSFetchedResultsController<List>
    private(set) var tags: NSFetchedResultsController<Tag>
    
    init() {
        
        lists = {
            let request: NSFetchRequest<List> = List.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            return NSFetchedResultsController(fetchRequest: request,
                                              managedObjectContext: AppDelegate.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        }()
        tags = {
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            request.resultType = .dictionaryResultType
            request.propertiesToFetch = ["name"]
            request.returnsDistinctResults = true
            return NSFetchedResultsController(fetchRequest: request,
                                              managedObjectContext: AppDelegate.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
        }()
    }
    
    func addNewList(title: String? = nil, todos: NSSet? = nil) {
        let newList = List(context: AppDelegate.viewContext)
        if let title = title { newList.title = title }
        if let todos = todos { newList.todos = todos }
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func remove(_ list: List) {
        AppDelegate.viewContext.delete(list)
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func todosFor(tag: Tag) -> NSFetchedResultsController<Todo> {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = NSPredicate(format: "ANY tags.name = @%", tag.name!)
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: AppDelegate.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
}
