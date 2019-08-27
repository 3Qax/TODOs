//
//  MenuViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UITableViewController {

    @IBOutlet var menuTableView: UITableView!
    private var isAddingNewList: Bool = false {
        didSet {
            plusBarButtonItem.isEnabled =  !isAddingNewList
            (menuTableView.headerView(forSection: 0) as? MenuHeader)?.styleAsEnabled = !isAddingNewList
        }
    }
    private var isListsSectionCollapsed: Bool = false
    private var isTagsSectionCollapsed: Bool = false
    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    let menu = Menu()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuHeaderNib = UINib(nibName: "MenuHeader", bundle: nil)
        menuTableView.register(menuHeaderNib, forHeaderFooterViewReuseIdentifier: "menuHeader")
        
        let menuItemNib = UINib(nibName: "MenuItem", bundle: nil)
        menuTableView.register(menuItemNib, forCellReuseIdentifier: "menuItem")
        
        menuTableView.reloadData()
        menu.lists.delegate = self
        menu.tags.delegate = self
        
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
            listVC.list = menu.lists.fetchedObjects![index]
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
            listForTagVC.list = menu.listFor(tag: menu.tags.fetchedObjects![index])
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return isListsSectionCollapsed ? 0 : menu.lists.fetchedObjects?.count ?? 0
        case 1:
            return isTagsSectionCollapsed ? 0 : menu.tags.fetchedObjects?.count ?? 0
        default:
            fatalError()
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "menuItem") as? MenuItem else {
            fatalError()
        }
        cell.delegate = self
        switch indexPath.section {
        case 0:
            cell.titleTextView.text = menu.lists.fetchedObjects![indexPath.item].title
        case 1:
            cell.titleTextView.text = menu.tags.fetchedObjects![indexPath.item].name
        default:
            fatalError()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            menu.remove(menu.lists.fetchedObjects![indexPath.item])
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let cell = tableView.cellForRow(at: indexPath) as? MenuItem, cell.titleTextView.isEditable {
                return
            }
            performSegue(withIdentifier: "showList", sender: self)
        case 1:
            performSegue(withIdentifier: "showListForTag", sender: self)
        default:
            fatalError("Invalid section")
        }
    }
    
}

// MARK: Handle adding new MenuItem (List)
extension MenuViewController: MenuItemDelegate {
    @IBAction func didTapAdd(_ sender: Any) {
        
        assert(!isAddingNewList, "didTapAdd should only be called if user isn't already in process of adding one")
        
        if isListsSectionCollapsed { toggleListSection() }
        
        let newList = menu.createNewEmptyList()
        guard let indexPathOfNewList = menu.lists.indexPath(forObject: newList) else {
            assert(false, "There always should be indexPath for newly created and inserted list")
        }
        guard let insertedMenuItem = menuTableView.cellForRow(at: indexPathOfNewList) as? MenuItem else {
            assert(false, "Cell inserted at indexPathOfNewList have to be of type MenuItem")
        }
        
        insertedMenuItem.titleTextView.isEditable = true
        insertedMenuItem.titleTextView.becomeFirstResponder()
        
        isAddingNewList = true
    }
    func textChanged() {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.menuTableView.beginUpdates()
                self.menuTableView.endUpdates()
            }
        }
    }
    func didEndEditingListName(sender: MenuItem) {
        if let index = menuTableView.indexPath(for: sender)?.item {
            // check if list name isnt jsut a bunch of whitespaces
            if !sender.titleTextView.text.allSatisfy({ $0.isWhitespace }) {
                menu.lists.fetchedObjects![index].title = sender.titleTextView.text
            } else {
                // if it and some tried saving it then delete it
                menu.remove(menu.lists.fetchedObjects![index])
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
            do { try AppDelegate.viewContext.save()
            } catch let err { fatalError(err.localizedDescription) }
        }
        isAddingNewList = false
    }
}

// MARK: Headers handling
extension MenuViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "menuHeader") else {
            fatalError()
        }
        guard let header = cell as? MenuHeader else {
            fatalError()
        }
        
        switch section {
        case 0:
            header.titleLabel.text = "Lists"
            header.onTap { [weak self] in self?.didTapListSectionHeader() }
            header.styleAsCollapsed = isListsSectionCollapsed
        case 1:
            header.titleLabel.text = "Tags"
            header.onTap { [weak self] in self?.didTapTagsSectionHeader() }
            header.styleAsCollapsed = isTagsSectionCollapsed
        default:
            fatalError("Asked for header for incorrect section")
        }
        
        return cell
    }
    func didTapListSectionHeader() {
        if !isAddingNewList { toggleListSection()
        } else { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    }
    
    func didTapTagsSectionHeader() {
        toggleTagsSection()
    }
}

// MARK: Handle model notifications
extension MenuViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        menuTableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        if anObject is List {
            switch type {
            case .insert:
                menuTableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                menuTableView.deleteRows(at: [indexPath!], with: .automatic)
            case .move:
                menuTableView.moveRow(at: indexPath!, to: newIndexPath!)
            case .update:
                menuTableView.reloadRows(at: [indexPath!], with: .automatic)
            @unknown default:
                assert(false, "Change of unknown type happened!")
            }
        }
        if anObject is Tag {
            // fetch request controller doesn't know that these results are in 2nd section of table view
            // so we have to account for that by changing section in indexPath and newIndexPath
            var correctIndexPath = indexPath
            correctIndexPath?.section = 1
            var correctNewIndexPath = newIndexPath
            correctNewIndexPath?.section = 1
            switch type {
            case .insert:
                menuTableView.insertRows(at: [correctNewIndexPath!], with: .automatic)
            case .delete:
                menuTableView.reloadSections(IndexSet(integer: 1), with: .fade)
            case .move:
                menuTableView.moveRow(at: correctIndexPath!, to: correctNewIndexPath!)
            case .update:
                menuTableView.reloadRows(at: [correctIndexPath!], with: .automatic)
            @unknown default:
                assert(false, "Change of unknown type happened!")
            }
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        menuTableView.endUpdates()
    }
}

// MARK: Section collapsing or expanding
extension MenuViewController {
    
    func toggleListSection() {
        isListsSectionCollapsed.toggle()
        menuTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func toggleTagsSection() {
        isTagsSectionCollapsed.toggle()
        menuTableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
}
