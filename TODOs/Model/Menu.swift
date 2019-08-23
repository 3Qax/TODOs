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
        let listsFetchRequest: NSFetchRequest<List> = NSFetchRequest(entityName: "List")
        listsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        listsFetchRequest.predicate = NSPredicate(format: "isForTag == NO")
        lists = NSFetchedResultsController(fetchRequest: listsFetchRequest,
                                           managedObjectContext: AppDelegate.viewContext,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)
        do { try lists.performFetch()
        } catch let err { fatalError(err.localizedDescription) }
        
        let tagsFetchRequest: NSFetchRequest<Tag> = NSFetchRequest(entityName: "Tag")
        tagsFetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        tags = NSFetchedResultsController(fetchRequest: tagsFetchRequest,
                                          managedObjectContext: AppDelegate.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
        
        do { try tags.performFetch()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func createNewEmptyList() -> List {
        let newList = List(entity: NSEntityDescription.entity(forEntityName: "List",
                                                              in: AppDelegate.viewContext)!,
                           insertInto: AppDelegate.viewContext)
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
        
        return newList
    }
    
    func remove(_ list: List) {
        AppDelegate.viewContext.delete(list)
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    // this functions generates fake list containing
    // all of the todos which have given tag assigned to them
    // it is neccessary to delete fake tag created that way after going back from ListForTagVC
    func listFor(tag: Tag) -> List {
        let newList = List(context: AppDelegate.viewContext)
        newList.title = tag.name
        newList.isForTag = true
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = NSPredicate(format: "ANY tags.name = %@", tag.name)
        newList.sortedTodos = NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: AppDelegate.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
        do { try newList.sortedTodos.performFetch()
        } catch let err { fatalError(err.localizedDescription) }
        return newList
    }
}
