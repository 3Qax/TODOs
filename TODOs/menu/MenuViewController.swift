//
//  MenuViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    @IBOutlet var menuTableView: UITableView!
    private var isListsSectionCollapsed: Bool = false
    private var isTagsSectionCollapsed: Bool = false
    var menu = Menu()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.canCancelContentTouches = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "showList" {
            guard let listVC = segue.destination as? ListViewController,
                  let indexOfSelectedList = tableView.indexPathForSelectedRow?.item else {
                fatalError()
            }
            listVC.title = menu.lists[indexOfSelectedList].name
            listVC.list = menu.lists[indexOfSelectedList]
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isListsSectionCollapsed ? 0 : menu.lists.count
        case 1:
            return isTagsSectionCollapsed ? 0 : 3
        default:
            fatalError()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuTableViewCell") as? MenuTableViewCell else {
            fatalError()
        }
        if indexPath.section == 0 {
            cell.titleLabel.text = menu.lists[indexPath.item].name
        }
        return cell
    }
    
}

// MARK: Headers handling
extension MenuTableViewController: MenuHeaderDelegate {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableCell(withIdentifier: "menuHeaderCell") as? MenuHeaderView else {
            fatalError()
        }
        
        switch section {
        case 0:
            header.setup(as: .lists)
        case 1:
            header.setup(as: .tags)
        default:
            fatalError("Asked for header for incorrect section")
        }
        header.delegate = self
        return header.contentView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func didTapHeader(sender: MenuHeaderView) {
        print("tappp")
        if let indexPath = menuTableView.indexPath(for: sender) {
            if indexPath.section == 0 {
                self.isListsSectionCollapsed.toggle()
                self.menuTableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            if indexPath.section == 1 {
                self.isTagsSectionCollapsed.toggle()
                self.menuTableView.reloadSections(IndexSet(integer: 1), with: .none)
            }
            
        }
    }
}
