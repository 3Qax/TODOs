//
//  MenuModel.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import Foundation
import RealmSwift

class Menu {
    private(set) var lists: Results<List>
    private(set) var tags: Results<Tag>
    private var realm: Realm
    
    init() {
        
        let config = Realm.Configuration(fileURL: Bundle.main.url(forResource: "default", withExtension: "realm"),
                                         readOnly: true)
        
        do { try realm = Realm(configuration: config) }
        catch let error { fatalError(error.localizedDescription) }
        
        print(realm.configuration.fileURL)
        lists = realm.objects(List.self)
        tags = realm.objects(Tag.self)
    }
}
