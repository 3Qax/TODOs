//
//  Tag.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import CoreData

@objc (Tag)
final class Tag: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    /// name of tag
    @NSManaged public var name: String

    /// todos to which this tag has been assigned
    @NSManaged public var todos: Set<Todo>

}

// MARK: Generated accessors for todos
extension Tag {

    @objc(addTodosObject:)
    @NSManaged public func addToTodos(_ value: Todo)

    @objc(removeTodosObject:)
    @NSManaged public func removeFromTodos(_ value: Todo)

    @objc(addTodos:)
    @NSManaged public func addToTodos(_ values: Set<Todo>)

    @objc(removeTodos:)
    @NSManaged public func removeFromTodos(_ values: Set<Todo>)

}
