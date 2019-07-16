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
    
    var list: List? {
        didSet {
            let request: NSFetchRequest<Todo> = Todo.fetchRequest()
            request.predicate = NSPredicate(format: "list == %@", list!)
            request.sortDescriptors = [NSSortDescriptor(key: "isDone", ascending: true),
                                       NSSortDescriptor(key: "name", ascending: true)]
            todos = NSFetchedResultsController(fetchRequest: request,
                                              managedObjectContext: AppDelegate.viewContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
            do { try  todos?.performFetch()
            } catch let err { fatalError(err.localizedDescription) }
            
            taskTableView.reloadData()
            todos?.delegate = self
        }
    }
    var todos: NSFetchedResultsController<Todo>?
    @IBOutlet weak var taskTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            if let taskVC = segue.destination as? TaskViewController {
                _ = taskVC.view
                let newTodo = Todo(context: AppDelegate.viewContext)
                list!.addToTodos(newTodo)
                taskVC.task = newTodo
                taskVC.state = .editing
                taskVC.title = "add todo"
            }
        }
        if segue.identifier == "showTaskDetails" {
            if let taskVC = segue.destination as? TaskViewController,
            let indexOfSelecctedTask = taskTableView.indexPathForSelectedRow?.item {
                _ = taskVC.view
                taskVC.task = todos!.fetchedObjects![indexOfSelecctedTask]
                taskVC.state = .viewing
                taskVC.title = "edit todo"
            }
        }
        
    }
    
    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "unwindToList" {
            if let taskVC = unwindSegue.source as? TaskViewController {
                if taskVC.task!.name!.allSatisfy({ $0.isWhitespace }) {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    list!.removeFromTodos(taskVC.task!)
                }
            }
        }
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            list!.removeFromTodos(todos!.fetchedObjects![indexPath.item])
        }
    }
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoWithTag") as? TodoTableViewCell else {
            fatalError()
        }
        
        cell.nameLabel.text = todos!.fetchedObjects![indexPath.item].name
        cell.shouldStypeAsDone = todos!.fetchedObjects![indexPath.item].isDone
        cell.delegate = self

        return cell
    }
    
}

extension ListViewController: TodoTableViewCellDelegate {
    func didTapCircle(sender: TodoTableViewCell) {
        if let index = taskTableView.indexPath(for: sender)?.item {
            if todos!.fetchedObjects![index].isDone {
                 todos!.fetchedObjects![index].set(isDone: false)
            } else {
                 todos!.fetchedObjects![index].set(isDone: true)
            }
        }
    }
}

extension ListViewController: NSFetchedResultsControllerDelegate {
    // swiftlint:disable line_length
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // swiftlint:enable line_length
        switch type {
        case .insert:
            taskTableView.beginUpdates()
            taskTableView.insertRows(at: [newIndexPath!], with: .automatic)
            taskTableView.endUpdates()
        case .delete:
            taskTableView.beginUpdates()
            taskTableView.deleteRows(at: [indexPath!], with: .automatic)
            taskTableView.endUpdates()
        case .move:
            taskTableView.beginUpdates()
            taskTableView.moveRow(at: indexPath!, to: newIndexPath!)
            taskTableView.endUpdates()
        case .update:
            taskTableView.beginUpdates()
            taskTableView.reloadRows(at: [indexPath!], with: .automatic)
            taskTableView.endUpdates()
        @unknown default:
            fatalError()
        }
    }
}
