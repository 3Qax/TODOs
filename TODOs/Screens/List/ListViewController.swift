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
    func didRequestedToEnterDetails(for todo: Todo)
    func didTapAddNewTodoTo(list: List)
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
        if allowsAddingAndEnteringDetails {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                target: self,
                                                                action: #selector(didTapPlusButton))
        }

        let listItemNib = UINib(nibName: ListItem.className, bundle: nil)
        customView.tableView.register(listItemNib, forCellReuseIdentifier: ListItem.className)

        list.sortedTodos.delegate = self
        customView.tableView.delegate = self
        customView.tableView.dataSource = self

    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "addTask" {
//            if let todoVC = segue.destination as? TodoViewController {
//                _ = todoVC.view
//                let newTodo = Todo(context: AppDelegate.viewContext)
//                newTodo.list = list
//                todoVC.todo = newTodo
//                todoVC.state = .editing
//                todoVC.title = "add todo"
//            }
//        }
//        if segue.identifier == "showTaskDetails" {
//            if let todoVC = segue.destination as? TodoViewController,
//            let indexOfSelectedTask = customView.tableView.indexPathForSelectedRow?.item {
//                _ = todoVC.view
//                todoVC.todo = list.sortedTodos.fetchedObjects![indexOfSelectedTask]
//                todoVC.state = .viewing
//                todoVC.title = "edit todo"
//            }
//        }
//    }
//
//    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
//        if unwindSegue.identifier == "unwindToList", let todoVC = unwindSegue.source as? TodoViewController {
//            todoVC.todo.didEndEditing()
//        }
//    }

    @objc func didTapPlusButton() {
        delegate?.didTapAddNewTodoTo(list: list)
    }

}

extension ListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            list.remove(todo: list.sortedTodos.fetchedObjects![indexPath.item])
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowsAddingAndEnteringDetails  {
            delegate?.didRequestedToEnterDetails(for: list.sortedTodos.fetchedObjects![indexPath.item])
        }
    }

}

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.sortedTodos.fetchedObjects!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListItem.className) as? ListItem else {
            fatalError()
        }

        cell.nameTextView.text = list.sortedTodos.fetchedObjects![indexPath.item].name
        cell.shouldStypeAsDone = list.sortedTodos.fetchedObjects![indexPath.item].isDone
//        list.sortedTodos.fetchedObjects![indexPath.item].isDone ? cell.styleAsDone() : cell.styleAsNotDone()
        cell.delegate = self

        return cell
    }

}

extension ListViewController: ListItemDelegate {

    func didTapCircle(sender: ListItem) {
        if let index = customView.tableView.indexPath(for: sender)?.item {
            list.sortedTodos.fetchedObjects![index].isDone.toggle()
            do { try AppDelegate.viewContext.save()
            } catch let err { fatalError(err.localizedDescription) }
            sender.updateStyling()
        }
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
                customView.tableView.moveRow(at: indexPath!, to: newIndexPath!)
            case .update:
                customView.tableView.reloadRows(at: [indexPath!], with: .automatic)
            @unknown default:
                assert(false, "Change of unknown type happened!")
            }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        customView.tableView.endUpdates()
    }

}