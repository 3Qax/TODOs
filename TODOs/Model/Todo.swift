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
    
    func set(name: String) {
        self.name = name
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func set(isDone: Bool) {
        self.isDone = isDone
        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
    func set(tagsNames: [String]) {
        
        // remove all of the tags of this todo
        self.removeFromTags(self.tags!)
        
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

        do { try AppDelegate.viewContext.save()
        } catch let err { fatalError(err.localizedDescription) }
    }
    
}
