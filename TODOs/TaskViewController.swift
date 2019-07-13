//
//  TaskViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 13/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import RealmSwift

class TaskViewController: UIViewController {
    
    enum State {
        case editing
        case viewing
    }
    
    var state: State = .editing {
        didSet {
            updateViewState()
        }
    }
    @IBOutlet weak var titleTextLabel: UITextField!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var isDoneSwitch: UISwitch!
    @IBOutlet weak var tagsTextLabel: UITextField!
    
    var task = Todo() {
        didSet {
            updateForChangedTask()
        }
    }
    var taskObservationToken: NotificationToken?
    
    func updateForChangedTask() {
        taskObservationToken?.invalidate()
        taskObservationToken = task.observe({ change in
            switch change {
            case .error(let err):
                fatalError(err.localizedDescription)
            case .change(let properties):
                for property in properties {
                    // swiftlint:disable force_cast
                    if property.name == "title" { self.titleTextLabel.text = (property.newValue as! String) }
                    if property.name == "isDone" { self.isDoneSwitch.isOn = (property.newValue as! Bool) }
                    // swiftlint:enable force_cast
                    
                }
            case .deleted:
                fatalError("Task can not be deleted in TaskVC")
            }
        })
        titleTextLabel.text = task.title
        isDoneSwitch.isOn = task.isDone
    }
    
    func updateViewState() {
        switch state {
        case .editing:
            titleTextLabel.isUserInteractionEnabled = true
            titleTextLabel.becomeFirstResponder()
            tagsTextLabel.isUserInteractionEnabled = true
            isDoneSwitch.isHidden = false
            stateLabel.text = "mark as done"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(didTapDone))
        case .viewing:
            titleTextLabel.isUserInteractionEnabled = false
            tagsTextLabel.isUserInteractionEnabled = false
            isDoneSwitch.isHidden = true
            stateLabel.text = task.isDone ? "Marked as done" : "Pending"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(didTapEdit))
        }
    }
    
    @objc func didTapDone() {
        task.set(title: titleTextLabel.text!)
        task.set(isDone: isDoneSwitch.isOn)
        self.performSegue(withIdentifier: "unwindToList", sender: self)
    }
    
    @objc func didTapEdit() {
        self.state = .editing
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        taskObservationToken?.invalidate()
    }

    deinit {
        taskObservationToken?.invalidate()
    }
    
}
