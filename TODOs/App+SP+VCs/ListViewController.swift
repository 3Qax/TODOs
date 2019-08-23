//
//  ListViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData

@IBDesignable
class ListViewController: UIViewController {
    
    var list: List!
    @IBOutlet weak var taskTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        list.sortedTodos.delegate = self
        self.title = list.title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            if let todoVC = segue.destination as? TodoViewController {
                _ = todoVC.view
                let newTodo = Todo(context: AppDelegate.viewContext)
                newTodo.list = list
                todoVC.todo = newTodo
                todoVC.state = .editing
                todoVC.title = "add todo"
            }
        }
        if segue.identifier == "showTaskDetails" {
            if let todoVC = segue.destination as? TodoViewController,
            let indexOfSelectedTask = taskTableView.indexPathForSelectedRow?.item {
                _ = todoVC.view
                todoVC.todo = list.sortedTodos.fetchedObjects![indexOfSelectedTask]
                todoVC.state = .viewing
                todoVC.title = "edit todo"
            }
        }
        
    }
    
    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "unwindToList", let todoVC = unwindSegue.source as? TodoViewController {
            todoVC.todo.didEndEditing()
        }
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            list!.remove(todo: list.sortedTodos.fetchedObjects![indexPath.item])
        }
    }
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.sortedTodos.fetchedObjects!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoWithTag") as? TodoTableViewCell else {
            fatalError()
        }
        
        cell.nameLabel.text = list.sortedTodos.fetchedObjects![indexPath.item].name
        cell.shouldStypeAsDone = list.sortedTodos.fetchedObjects![indexPath.item].isDone
        cell.delegate = self

        return cell
    }
    
}

extension ListViewController: TodoTableViewCellDelegate {
    func didTapCircle(sender: TodoTableViewCell) {
        if let index = taskTableView.indexPath(for: sender)?.item {
            list.sortedTodos.fetchedObjects![index].isDone.toggle()
            do { try AppDelegate.viewContext.save()
            } catch let err { fatalError(err.localizedDescription) }
        }
    }
}

extension ListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        taskTableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
            switch type {
            case .insert:
                taskTableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                taskTableView.deleteRows(at: [indexPath!], with: .automatic)
            case .move:
                taskTableView.moveRow(at: indexPath!, to: newIndexPath!)
            case .update:
                taskTableView.reloadRows(at: [indexPath!], with: .automatic)
            @unknown default:
                assert(false, "Change of unknown type happened!")
            }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        taskTableView.endUpdates()
    }
}
