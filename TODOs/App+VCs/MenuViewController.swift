//
//  MenuViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import RealmSwift

class MenuTableViewController: UITableViewController {

    @IBOutlet var menuTableView: UITableView!
    private var isListsSectionCollapsed: Bool = false
    private var isTagsSectionCollapsed: Bool = false
    var menu: Menu = Menu.common
    var listsObservationToken: NotificationToken?
    var tagsObservationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.canCancelContentTouches = false
        listsObservationToken = menu.lists.observe({ [weak self] changes in
            switch changes {
            case .initial:
                self?.menuTableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self?.menuTableView.beginUpdates()
                // When adding new cell
                self?.menuTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                
                self?.menuTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                
                self?.menuTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self?.menuTableView.endUpdates()
                
                if let item = insertions.last,
                let insertedCell = self?.menuTableView.cellForRow(at: IndexPath(item: item, section: 0)) as? MenuTableViewCell {
                    insertedCell.titleTextView.isEditable = true
                    insertedCell.titleTextView.becomeFirstResponder()
                }
                
            case .error(let err):
                fatalError(err.localizedDescription)
            }
        })
//         oh god...
//         https://github.com/realm/realm-cocoa/issues/5528
        tagsObservationToken = menu.tags.observe({ [weak self] changes in
            switch changes {
            case .initial:
                self?.menuTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            case .update(_, let deletions, let insertions, let modifications):
                self?.menuTableView.beginUpdates()
                self?.menuTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 1) }),
                                               with: .automatic)
                self?.menuTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 1)}),
                                               with: .automatic)
                self?.menuTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 1) }),
                                               with: .automatic)
                self?.menuTableView.endUpdates()
            case .error(let err):
                fatalError(err.localizedDescription)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        if identifier == "showList" {
            guard let listVC = segue.destination as? ListViewController,
            let section = tableView.indexPathForSelectedRow?.section,
            let index = tableView.indexPathForSelectedRow?.item else {
                fatalError()
            }
            guard section == 0 else {
                fatalError("showList segue should only be performed for cells (actual lists) from section 0")
            }
            listVC.title = menu.lists[index].name
            listVC.list = menu.lists[index]
        }
        
        if identifier == "showListForTag" {
            guard let listForTagVC = segue.destination as? ListForTagViewController,
                let section = tableView.indexPathForSelectedRow?.section,
                let index = tableView.indexPathForSelectedRow?.item else {
                    fatalError()
            }
            guard section == 1 else {
                fatalError("showListForTag segue should only be performed for cells (tags) from section 1")
            }
            listForTagVC.title = menu.tags[index].name
            listForTagVC.list = menu.todosFor(tag: menu.tags[index])
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isListsSectionCollapsed ? 0 : menu.lists.count
        case 1:
            return isTagsSectionCollapsed ? 0 : menu.tags.count
        default:
            fatalError()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuTableViewCell") as? MenuTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        switch indexPath.section {
        case 0:
            cell.titleTextView.text = menu.lists[indexPath.item].name
        case 1:
            cell.titleTextView.text = menu.tags[indexPath.item].name
        default:
            fatalError()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 { return true }
        return false
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            menu.remove(menu.lists[indexPath.item])
        }
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        let newList = List()
        menu.add(newList)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showList", sender: self)
        case 1:
            performSegue(withIdentifier: "showListForTag", sender: self)
        default:
            fatalError("Invalid section")
        }
    }
    
    deinit {
        listsObservationToken?.invalidate()
        tagsObservationToken?.invalidate()
    }
}

// MARK: Handle adding new cells
extension MenuTableViewController: MenuTableViewCellDelegate {
    func didEndEditingListName(sender: MenuTableViewCell) {
        if let index = menuTableView.indexPath(for: sender)?.item {
            if sender.titleTextView.text.allSatisfy({ $0.isWhitespace }) {
                menu.remove(menu.lists[index])
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            menu.lists[index].set(name: sender.titleTextView.text)
        }
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
