//
//  PrimarySplitController.swift
//  TODOs
//
//  Created by Jakub Towarek on 15/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

class PrimarySplitViewController: UISplitViewController,
UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
