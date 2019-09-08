//
//  ListViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData

protocol ListViewControllerDelegate: AnyObject {
    func didRequestToEnterDetails(of todo: Todo)
    func didRequestToAddNewTodo(to list: List)
}

final class ListViewController: UIViewController {

    private var customView: ListView { return self.view as! ListView }
    private var allowsAddingAndEnteringDetails: Bool
    private weak var delegate: ListViewControllerDelegate?
    private var list: List

    init(list: List, allowsAddingAndEnteringDetails: Bool, delegate: ListViewControllerDelegate? = nil) {
        self.list = list
        self.allowsAddingAndEnteringDetails = allowsAddingAndEnteringDetails
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ListView.instanceFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = list.title
        if self.allowsAddingAndEnteringDetails {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                target: self,
                                                                action: #selector(didTapPlus))
        }

        let listItemNib = UINib(nibName: ListItem.className, bundle: nil)
        customView.tableView.register(listItemNib, forCellReuseIdentifier: ListItem.className)

        list.sortedTodos.delegate = self
        customView.tableView.delegate = self
        customView.tableView.dataSource = self

    }

    /// Called on tap of plus button in navigation bar
    @objc private func didTapPlus() {
        delegate?.didRequestToAddNewTodo(to: list)
    }

}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowsAddingAndEnteringDetails
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            list.remove(todo: list.sortedTodos.fetchedObjects![indexPath.item])
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowsAddingAndEnteringDetails {
            let selectedTodo = list.sortedTodos.fetchedObjects![indexPath.item]
            delegate?.didRequestToEnterDetails(of: selectedTodo)
        } else { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    }

}

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.sortedTodos.fetchedObjects!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListItem.className) as? ListItem else {
            assert(false, "Can not dequeue cell")
            return UITableViewCell()
        }

        cell.nameTextView.text = list.sortedTodos.fetchedObjects![indexPath.item].name
        cell.shouldStyleAsDone = list.sortedTodos.fetchedObjects![indexPath.item].isDone
        cell.updateStyling()
        cell.delegate = self

        return cell
    }

}

extension ListViewController: ListItemDelegate {

    func didTapCircle(sender: ListItem) {

        guard let index = customView.tableView.indexPath(for: sender)?.item else {
            assert(false, "Can not get index of ListItem")
            sender.updateStyling()
            return
        }

        list.sortedTodos.fetchedObjects![index].toggleState()
        sender.shouldStyleAsDone.toggle()

        do { try AppDelegate.viewContext.save()
        } catch let err { assert(false, "Something went wrong when saving: \(err)") }

    }

}

extension ListViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

            switch type {
            case .insert:
                customView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                customView.tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .move:
                customView.tableView.deleteRows(at: [indexPath!], with: .automatic)
                customView.tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .update:
                customView.tableView.reloadRows(at: [indexPath!], with: .automatic)
            @unknown default:
                assert(false, "Change of unknown type happened!")
                return
            }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.endUpdates()
    }

}
