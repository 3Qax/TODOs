//
//  ListForTagViewController
//  TODOs
//
//  Created by Jakub Towarek on 14/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import RealmSwift

class ListForTagViewController: UIViewController {
    
    var list = AnyRealmCollection(RealmSwift.List<Todo>()) {
        didSet {
            listObservationToken?.invalidate()
            listObservationToken = list.observe({ [weak self] changes in
                switch changes {
                case .initial:
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
        fatalError("You shouldn't be able to go anywhere")
    }
    
    @IBAction func unwindToList(_ unwindSegue: UIStoryboardSegue) {
    }
}

extension ListForTagViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoWithTag") as? TodoTableViewCell else {
            fatalError()
        }
        
        cell.nameLabel.text = list[indexPath.item].title
        cell.shouldStypeAsDone = list[indexPath.item].isDone
        cell.delegate = self
        
        return cell
    }
    
}

extension ListForTagViewController: TodoTableViewCellDelegate {
    func didTapCircle(sender: TodoTableViewCell) {
        if let index = taskTableView.indexPath(for: sender)?.item {
            if list[index].isDone {
                list[index].set(isDone: false)
            } else {
                list[index].set(isDone: true)
            }
        }
    }
}
