//
//  MenuModel.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import CoreData

final class Menu {

    // MARK: - Properties

    /// NSFetchedResultsController containg all exisiting lists.
    /// Sorted by name in alphametical order.
    public let lists: NSFetchedResultsController<List> = {

        let fetchRequest: NSFetchRequest<List> = NSFetchRequest(entityName: "List")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isForTag == NO")

        let result = NSFetchedResultsController(fetchRequest: fetchRequest,
                                           managedObjectContext: AppDelegate.viewContext,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)

        do { try result.performFetch()
        } catch let err { assert(false, err.localizedDescription) }

        return result

    }()

    /// NSFetchedResultsController containing all exisitng tags
    /// Sorted by name in alphametical order.
    public let tags: NSFetchedResultsController<Tag> = {

        let fetchRequest: NSFetchRequest<Tag> = NSFetchRequest(entityName: "Tag")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let result = NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: AppDelegate.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)

        do { try result.performFetch()
        } catch let err { assert(false, err.localizedDescription) }

        return result

    }()

    // MARK: - Functions

    /// Creates new empty list
    public func createNewEmptyList() -> List {

        let newList = List(entity: NSEntityDescription.entity(forEntityName: "List",
                                                              in: AppDelegate.viewContext)!,
                           insertInto: AppDelegate.viewContext)

        do { try AppDelegate.viewContext.save()
        } catch let err { assert(false, err.localizedDescription) }

        return newList
    }

    /// Deletes given list
    /// - Parameter list: list to be deleted
    public func delete(list: List) {

        AppDelegate.viewContext.delete(list)

        do { try AppDelegate.viewContext.save()
        } catch let err { assert(false, err.localizedDescription) }

    }

}
