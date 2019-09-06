//
//  List.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import CoreData

@objc (List)
final class List: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    /// Generates fake list containing todos having given tag assigned to them.
    /// - Warning: It is neccessary to delete list generated that way after it has been used
    /// - Parameter tag: The tag for which list is generated
    /// - Returns: Fake list
    static func generateFakeList(for tag: Tag) -> List {

        // generate new list and set it up
        let newList = List(context: AppDelegate.viewContext)
        newList.title = tag.name
        newList.isForTag = true

        // create new fetch request to get todos which have given tag assigned to them
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = NSPredicate(format: "ANY tags.name = %@", tag.name)

        // inject fetched results controller, created based on fetch request, to new list
        newList.sortedTodos = NSFetchedResultsController(fetchRequest: request,
                                                         managedObjectContext: AppDelegate.viewContext,
                                                         sectionNameKeyPath: nil,
                                                         cacheName: nil)
        // perform initial fetch
        do { try newList.sortedTodos.performFetch()
        } catch let err { assert(false, err.localizedDescription) }

        return newList

    }

    /// Property determining wether list is actual list or just a fake list
    @NSManaged public var isForTag: Bool

    /// Title of list
    @NSManaged public var title: String

    /// Todos in list
    @NSManaged public var todos: Set<Todo>

    /// FetchedResultsController of todos in list. Use this object as datasource for tableView of todos.
    ///
    /// Sorted by:
    /// 1) isDone (first appear todos not marked as done)
    /// 2) alphabetical order
    lazy var sortedTodos: NSFetchedResultsController<Todo> = {

        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        request.predicate = NSPredicate(format: "list == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true),
                                   NSSortDescriptor(key: "name", ascending: true)]

        let sortedTodos = NSFetchedResultsController(fetchRequest: request,
                                                 managedObjectContext: AppDelegate.viewContext,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
        do { try  sortedTodos.performFetch()
        } catch let err { fatalError(err.localizedDescription) }

        return sortedTodos

    }()

    /// Removes given todo from list.
    /// - Parameter todo: The todo to be deleted
    func remove(todo: Todo) {
        AppDelegate.viewContext.delete(todo)
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }

}

// MARK: - Automatically generated accessors for todos
extension List {

    @objc(addTodosObject:)
    @NSManaged public func addToTodos(_ value: Todo)

    @objc(removeTodosObject:)
    @NSManaged public func removeFromTodos(_ value: Todo)

    @objc(addTodos:)
    @NSManaged public func addToTodos(_ values: Set<Todo>)

    @objc(removeTodos:)
    @NSManaged public func removeFromTodos(_ values: Set<Todo>)

}
