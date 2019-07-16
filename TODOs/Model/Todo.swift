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
    
    func set(tags: [String]) {
        self.removeFromTags(self.tags!)
        tags.forEach({ tagName in
            let tag = Tag(entity: NSEntityDescription.entity(forEntityName: "Tag",
                                                             in: AppDelegate.viewContext)!,
                          insertInto: AppDelegate.viewContext)
            tag.name = tagName
            tag.todo = self
            do { try AppDelegate.viewContext.save()
            } catch let err { fatalError(err.localizedDescription) }
        })

    }
}
