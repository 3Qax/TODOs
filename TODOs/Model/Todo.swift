//
//  Todo.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import CoreData

@objc (Todo)
final class Todo: NSManagedObject {

    enum NameSettingErrors: Error {
        case blankName
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    /// determins whether todo is done or not
    @NSManaged public var isDone: Bool

    /// name of the todo
    @NSManaged public var name: String

    /// list to which todo belongs
    @NSManaged public var list: List

    /// tags assigned to todo
    @NSManaged public var tags: Set<Tag>

    // MARK: - Functions

    /// Sets new title after validation
    /// - Parameter name: Name to set
    func set(name: String) -> Result<Void, NameSettingErrors> {

        guard !name.allSatisfy({ $0.isWhitespace }) else {
            return .failure(.blankName)
        }

        let trimmmedName = name.trimmingCharacters(in: .whitespaces)
        self.name = trimmmedName

        return .success(())

    }

    /// Assigns new tags to todo, erasing tags that are currently assigned.
    /// - Important: Calling this function will make todo have only tags specified as parameter.
    /// - Warning: Do not assign tags directly!
    /// - Parameter tags: Array of names of Tags which todo should have eventually assigned
    func assign(tags: [String]) {

        // unassign all curently assigned tags
        // see prepareForDeletion() for more info
        self.tags.forEach({ tag in
            if tag.todos.count == 1 {
                // if a owned tag has only 1 todo (this todo) then delete it
                AppDelegate.viewContext.delete(tag)
            } else {
                // if it has more then delete only self from it's todos
                tag.removeFromTodos(self)
            }
        })

        // for each new tag check if there is already such a tag
        tags.forEach({ tagName in

            // create a fetch request for a tag with name matching tagName
            let request: NSFetchRequest<Tag> = NSFetchRequest(entityName: "Tag")
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "name == %@", tagName)

            let tagFetchResult = try? AppDelegate.viewContext.fetch(request) as [Tag]

            // if fetch request result is empty, it means that such a tag does't exist
            guard let suchTagDoesntExists = tagFetchResult?.isEmpty else {
                assert(false, "Apparently tag tetch request failed since result is nil")
                return
            }

            switch suchTagDoesntExists {

            case true:
                // create one and assign that tag to self
                let entity = NSEntityDescription.entity(forEntityName: "Tag", in: AppDelegate.viewContext)!
                let newTag = Tag(entity: entity, insertInto: AppDelegate.viewContext)
                newTag.name = tagName
                self.addToTags(newTag)
            case false:
                // add self to todos of that tag
                tagFetchResult?.first?.addToTodos(self)
            }

        })

    }

    /// Toogles state of todo
    func toggleState() {
        self.isDone.toggle()
    }

    /// Checks if deletion would leave any ghost tags (tags which are not not assign to any todo )
    /// If there is such a tag then it gets deleted
    override func prepareForDeletion() {

        super.prepareForDeletion()

        tags.forEach({ tag in

            let numberOfTodosReferencingTag = tag.todos.count

            // if the count is equal to 1, this todo is the only one referencing it
            if numberOfTodosReferencingTag == 1 {
                // since this todo is about to be deleted that tag should be deleted too
                AppDelegate.viewContext.delete(tag)
            } else {
                // if not then simply unassign tag from self
                tag.removeFromTodos(self)
            }

        })

    }

}

// MARK: - Automatically generated accessors for tags
extension Todo {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: Set<Tag>)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: Set<Tag>)

}
