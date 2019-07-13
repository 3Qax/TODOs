//
//  ListViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import RealmSwift

@IBDesignable
class ListViewController: UIViewController {
    

    
    var list = List() {
        didSet {
            listObservationToken?.invalidate()
            listObservationToken = list.todos.observe({ [weak self] changes in
                switch changes {
                case .initial(_):
                    self?.taskTableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    self?.taskTableView.beginUpdates()
                    // When adding new cell
                    self?.taskTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                                   with: .automatic)
                    
                    self?.taskTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                                   with: .automatic)
                    
                    self?.taskTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                                   with: .automatic)
                    self?.taskTableView.endUpdates()
                case .error(let err):
                    fatalError(err.localizedDescription)
                }
            })
        }
    }
    var listObservationToken: NotificationToken?
    @IBOutlet weak var taskTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            if let taskVC = segue.destination as? TaskViewController {
                _ = taskVC.view
                taskVC.state = .editing
                taskVC.title = "add todo"
            }
        }
        if segue.identifier == "showTaskDetails" {
            if let taskVC = segue.destination as? TaskViewController,
            let indexOfSelecctedTask = taskTableView.indexPathForSelectedRow?.item {
                _ = taskVC.view
                taskVC.task = list.todos[indexOfSelecctedTask]
                taskVC.state = .viewing
                taskVC.title = "edit todo"
            }
        }
        
    }
    
    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}

extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoWithTag") as? TodoTableViewCell else {
            fatalError()
        }
        
        cell.nameLabel.text = list.todos[indexPath.item].title
        if list.todos[indexPath.item].isDone { cell.markAsDone() }

        return cell
    }
    
}
