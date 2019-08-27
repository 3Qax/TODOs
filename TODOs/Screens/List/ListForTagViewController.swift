//
//  ListForTagViewController
//  TODOs
//
//  Created by Jakub Towarek on 14/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData

class ListForTagViewController: ListViewController {
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            AppDelegate.viewContext.delete(list)
        }
    }
    
}
