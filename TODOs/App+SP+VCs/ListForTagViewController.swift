//
//  ListForTagViewController
//  TODOs
//
//  Created by Jakub Towarek on 14/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData

class ListForTagViewController: UIViewController {
    
    var todos: NSFetchedResultsController<Todo>? {
        didSet {
            do { try todos?.performFetch()
            } catch let err { fatalError(err.localizedDescription) }
            todos?.delegate = self
            taskTableView.reloadData()
        }
    }

    @IBOutlet weak var taskTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        fatalError("You shouldn't be able to go anywhere")
    }
    
    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
    }
}

extension ListForTagViewController: UITableViewDataSource {
    
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

extension ListForTagViewController: TodoTableViewCellDelegate {
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

extension ListForTagViewController: NSFetchedResultsControllerDelegate {
    // swiftlint:disable line_length
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // swiftlint:enable line_length
        guard let indexPath = indexPath else { fatalError() }
        switch type {
        case .insert:
            taskTableView.beginUpdates()
            taskTableView.insertRows(at: [indexPath], with: .automatic)
            taskTableView.endUpdates()
        case .delete:
            taskTableView.beginUpdates()
            taskTableView.deleteRows(at: [indexPath], with: .automatic)
            taskTableView.endUpdates()
        case .move:
            taskTableView.beginUpdates()
            taskTableView.moveRow(at: indexPath, to: newIndexPath!)
            taskTableView.endUpdates()
        case .update:
            taskTableView.beginUpdates()
            taskTableView.reloadRows(at: [indexPath], with: .automatic)
            taskTableView.endUpdates()
        @unknown default:
            fatalError()
            
        }
    }
}
