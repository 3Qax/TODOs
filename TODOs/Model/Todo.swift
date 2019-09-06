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

    // TODO: think of better name for that todo
    func didEndEditing() {
        if self.name.allSatisfy({ $0.isWhitespace }) {
            AppDelegate.viewContext.delete(self)
        }
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }

    // TODO: create summary of this function
    func set(tagsNames: [String]) {

        // remove all of the tags of this todo
        // if a owned tag has only 1 todo (this todo) then delete it
        // since each tag should have at least 1
        // if it has more then delete only self from it's todos
        tags.forEach({ tag in
            if tag.todos.count == 1 {
                AppDelegate.viewContext.delete(tag)
            } else {
                tag.removeFromTodos(self)
            }
        })

        // for each new tag check if there is already such a tag
        tagsNames.forEach({ tagName in

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
