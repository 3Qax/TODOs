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
    private let menu = Menu()

    private var isAddingNewList: Bool = false { didSet { updateState() } }
    private var isListsSectionCollapsed: Bool = false
    private var isTagsSectionCollapsed: Bool = false

    private var addNewListBarButtonItem: UIBarButtonItem?
    private var saveBarButtonItem: UIBarButtonItem?

    weak var delegate: MenuViewControllerDelegate?

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
        addNewListBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddNewList))
        saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
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

    // MARK: - Bar buttons items tap handlers

    /// This function should be called on tap of addNewListBarButtonItem.
    /// Tells model to create new list, then it enters list name editing state.
    @objc private func didTapAddNewList() {

        guard !isAddingNewList else { return }

        if isListsSectionCollapsed { toggleListSection() }

        let newList = menu.createNewEmptyList()
        guard let indexPathOfNewList = menu.lists.indexPath(forObject: newList) else {
            assert(false, "There always should be indexPath for newly created and inserted list")
            return
        }
        guard let insertedMenuItem = customView.tableView.cellForRow(at: indexPathOfNewList) as? MenuItem else {
            assert(false, "Cell inserted at indexPathOfNewList have to be of type MenuItem")
            return
        }

        insertedMenuItem.titleTextView.isEditable = true
        insertedMenuItem.titleTextView.becomeFirstResponder()

        isAddingNewList = true
    }

    /// This function should be called on tap of saveBarButtonItem and only when VC isAddingNewList.
    @objc private func didTapSave() {

        guard isAddingNewList else { return }

        let cellIndexPath = IndexPath(row: 0, section: 0)

        guard let cell = customView.tableView.cellForRow(at: cellIndexPath) as? MenuItem else {
            assert(false, "Cannot cast cell as MenuItem")
            return
        }

        let titleToSet: String = cell.titleTextView.text
        let newList = menu.lists.fetchedObjects![0]

        switch newList.set(title: titleToSet) {
        case .success:
            cell.titleTextView.isEditable = false
            self.isAddingNewList = false
        case .failure(let reason):
            switch reason {
            case .emptyTitle:
                let alert = UIAlertController(title: "Incorrect title",
                                              message: "Title cannot be empty.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            case .blankTitle:
                let alert = UIAlertController(title: "Incorrect title",
                                              message: "Title cannot consist only of whitespaces.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            case .duplicateTitle:
                let alert = UIAlertController(title: "Incorrect title",
                                              message: "Title have to be unique.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }

    }

    // MARK: - TableView section's headers tap handlers

    private func didTapListSectionHeader() {
        // make sure user is not in the process of adding new list before toggling
        if !isAddingNewList { toggleListSection()
        } else { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    }

    private func didTapTagsSectionHeader() {
        toggleTagsSection()
    }

    // MARK: - Sections collapsing and expanding handlers

    func toggleListSection() {
        isListsSectionCollapsed.toggle()
        customView.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    func toggleTagsSection() {
        isTagsSectionCollapsed.toggle()
        customView.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }

    // FIXME: make here meaningful MARK

    func updateState() {
        navigationItem.rightBarButtonItem = isAddingNewList ? saveBarButtonItem : addNewListBarButtonItem
        (customView.tableView.headerView(forSection: 0) as? MenuHeader)?.styleAsEnabled = !isAddingNewList
    }

}

// MARK: - UITableViewDelegate methods
extension MenuViewController: UITableViewDelegate {

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

// MARK: - UITableViewDataSource methods
extension MenuViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

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
            menu.delete(list: menu.lists.fetchedObjects![indexPath.item])
        }
    }

}

// MARK: - MenuItemDelegate methods
extension MenuViewController: MenuItemDelegate {

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

    /// This function gets called when users taps return on a keyboard while editing MenuItem titleTextView
    func shouldEndEditing(sender: MenuItem) -> Bool {
        let titleToSet: String = sender.titleTextView.text
        let newList = menu.lists.fetchedObjects![0]

        switch newList.set(title: titleToSet) {
        case .success:
            self.isAddingNewList = false
            return true
        case .failure(let reason):
            switch reason {
            case .emptyTitle:
                let alert = UIAlertController(title: "Incorrect title",
                                              message: "Title cannot be empty.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            case .blankTitle:
                let alert = UIAlertController(title: "Incorrect title",
                                              message: "Title cannot consist only of whitespaces.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            case .duplicateTitle:
                let alert = UIAlertController(title: "Incorrect title",
                                              message: "Title have to be unique.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            return false
        }
    }

}

// MARK: - NSFetchedResultsControllerDelegate methods
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
                customView.tableView.deleteRows(at: [correctIndexPath!], with: .automatic)
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
