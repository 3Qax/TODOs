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
class Todo: NSManagedObject {

    func didEndEditing() {
        if self.name.allSatisfy({ $0.isWhitespace }) {
            AppDelegate.viewContext.delete(self)
        }
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }

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
            assert(tagFetchResult != nil, "Fetching of tag should never fail")
            // if fetch request returned a tag, it means that there already is such a tag
            let suchTagDoesntExists = tagFetchResult?.isEmpty

            if let suchTagDoesntExists = suchTagDoesntExists {
                if suchTagDoesntExists {
                    // create one and add self to todos of that tag
                    let entity = NSEntityDescription.entity(forEntityName: "Tag", in: AppDelegate.viewContext)!
                    let newTag = Tag(entity: entity, insertInto: AppDelegate.viewContext)
                    newTag.name = tagName
                    newTag.addToTodos(self)
                } else {
                    // add self to todos of that tag
                    tagFetchResult?.first?.addToTodos(self)
                }
            }
        })

    }

    override func prepareForDeletion() {
        super.prepareForDeletion()
        tags.forEach({ tag in
            if tag.todos.count == 1 {
                AppDelegate.viewContext.delete(tag)
            } else {
                tag.removeFromTodos(self)
            }
        })
    }

}

extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var isDone: Bool
    @NSManaged public var name: String
    @NSManaged public var list: List
    @NSManaged public var tags: Set<Tag>

}

// MARK: Generated accessors for tags
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
