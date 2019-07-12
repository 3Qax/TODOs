//
//  ListViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

@IBDesignable
class ListViewController: UIViewController {
    var list = List()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(list)
    }

}

extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(list.todos.count)
        return list.todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoWithTag") as? TodoTableViewCell else {
            fatalError()
        }
        
        cell.nameLabel.text = list.todos[indexPath.item].title

        return cell
    }
    
}
