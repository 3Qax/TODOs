//
//  MenuViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData

protocol MenuViewControllerDelegate: AnyObject {
    func didTap(list: List)
    func didTap(tag: Tag)
}

final class MenuViewController: UIViewController {

    private var customView: MenuView { return self.view as! MenuView }
    private var isAddingNewList: Bool = false {
        didSet {
            addNewListBarButtonItem.isEnabled =  !isAddingNewList
            (customView.tableView.headerView(forSection: 0) as? MenuHeader)?.styleAsEnabled = !isAddingNewList
        }
    }
    private var isListsSectionCollapsed: Bool = false
    private var isTagsSectionCollapsed: Bool = false
    // TODO: make that var optional
    private var addNewListBarButtonItem: UIBarButtonItem!
    weak var delegate: MenuViewControllerDelegate?
    private let menu = Menu()

    init(delegate: MenuViewControllerDelegate? = nil) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = MenuView.instanceFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "TODOs by JT"
        addNewListBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                       target: self,
                                                       action: #selector(didTapAddNewList))
        navigationItem.rightBarButtonItem = addNewListBarButtonItem

        let menuHeaderNib = UINib(nibName: MenuHeader.className, bundle: nil)
        customView.tableView.register(menuHeaderNib, forHeaderFooterViewReuseIdentifier: MenuHeader.className)

        let menuItemNib = UINib(nibName: MenuItem.className, bundle: nil)
        customView.tableView.register(menuItemNib, forCellReuseIdentifier: MenuItem.className)

        customView.tableView.delegate = self
        customView.tableView.dataSource = self

        menu.lists.delegate = self
        menu.tags.delegate = self

    }

}

extension MenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isListsSectionCollapsed ? 0 : menu.lists.fetchedObjects?.count ?? 0
        } else if section == 1 {
            return isTagsSectionCollapsed ? 0 : menu.tags.fetchedObjects?.count ?? 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuItem.className) as? MenuItem else {
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            menu.remove(menu.lists.fetchedObjects![indexPath.item])
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // do not navigate anywhere if user selects cell while it's name is being edited
        // TODO: if users taps cell during editing and it's name isn't empty save it and go to the listVC
        guard let cell = tableView.cellForRow(at: indexPath) as? MenuItem, !cell.titleTextView.isEditable else {
            return
        }

        if indexPath.section == 0, let list = menu.lists.fetchedObjects?[indexPath.row] {
            delegate?.didTap(list: list)
        }

        if indexPath.section == 1, let tag = menu.tags.fetchedObjects?[indexPath.row] {
            delegate?.didTap(tag: tag)
        }

    }

}

// MARK: - Adding new List and editing it's name handlers
extension MenuViewController: MenuItemDelegate {

    /// This function should be called on tap of add button in navigation bar.
    /// It tells model to create new list, then it enters list name editing state.
    @objc func didTapAddNewList() {

        assert(!isAddingNewList, "didTapAdd should only be called if user isn't already in process of adding one")

        if isListsSectionCollapsed { toggleListSection() }

        let newList = menu.createNewEmptyList()
        guard let indexPathOfNewList = menu.lists.indexPath(forObject: newList) else {
            assert(false, "There always should be indexPath for newly created and inserted list")
        }
        guard let insertedMenuItem = customView.tableView.cellForRow(at: indexPathOfNewList) as? MenuItem else {
            assert(false, "Cell inserted at indexPathOfNewList have to be of type MenuItem")
        }

        insertedMenuItem.titleTextView.isEditable = true
        insertedMenuItem.titleTextView.becomeFirstResponder()

        isAddingNewList = true
    }

    /// This function is getting called by MenuItem which titleTextView.text changed. Calling beginUpdates() and
    /// endUpdates() ensures that the cursor in titleTextView is allways fully visible (never goes behind keyboard)
    /// by scrolling tableView up if titleTextView.text expanded so much, that such condition occures.
    func textChanged() {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.customView.tableView.beginUpdates()
                self.customView.tableView.endUpdates()
            }
        }
    }

    /// This function gets called when users ends editing list name (taps return on a keyboard)
    func didEndEditingListName(sender: MenuItem) {
        if let index = customView.tableView.indexPath(for: sender)?.item {
            // check if list name isn't just a bunch of whitespaces
            if !sender.titleTextView.text.allSatisfy({ $0.isWhitespace }) {
                // if it isn't then set the title to entered text
                menu.lists.fetchedObjects![index].title = sender.titleTextView.text
            } else {
                // if it delete it
                menu.remove(menu.lists.fetchedObjects![index])
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
            // in both cases save context
            do { try AppDelegate.viewContext.save()
            } catch let err { fatalError(err.localizedDescription) }
        }
        // leave list name editing state
        isAddingNewList = false
    }
}

// MARK: - Headers configuration and callbacks
extension MenuViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: MenuHeader.className) else {
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
        // make sure user is not in the process of adding new list before toggling
        if !isAddingNewList { toggleListSection()
        } else { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    }

    func didTapTagsSectionHeader() {
        toggleTagsSection()
    }

}

// MARK: - Model changes handling functions
extension MenuViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        if anObject is List {
            switch type {
            case .insert:
                customView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                customView.tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .move:
                customView.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            case .update:
                customView.tableView.reloadRows(at: [indexPath!], with: .automatic)
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
                customView.tableView.insertRows(at: [correctNewIndexPath!], with: .automatic)
            case .delete:
                customView.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
            case .move:
                customView.tableView.moveRow(at: correctIndexPath!, to: correctNewIndexPath!)
            case .update:
                customView.tableView.reloadRows(at: [correctIndexPath!], with: .automatic)
            @unknown default:
                assert(false, "Change of unknown type happened!")
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.endUpdates()
    }

}

// MARK: - Sections collapsing and expanding handlers
extension MenuViewController {

    func toggleListSection() {
        isListsSectionCollapsed.toggle()
        customView.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    func toggleTagsSection() {
        isTagsSectionCollapsed.toggle()
        customView.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }

}
