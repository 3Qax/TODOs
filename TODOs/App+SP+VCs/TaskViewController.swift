//
//  TaskViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 13/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData
import WSTagsField

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
    @IBOutlet weak var tagsLabel: UILabel!
    let tagsField = WSTagsField()
    
    var task: Todo? {
        didSet {
            titleTextLabel.text = task!.name
            isDoneSwitch.isOn = task!.isDone
            task!.tags?.forEach({ tagsField.addTag(($0 as? Tag)!.name!) })
        }
    }
    
    func updateViewState() {
        switch state {
        case .editing:
            titleTextLabel.isUserInteractionEnabled = true
            titleTextLabel.becomeFirstResponder()
            tagsField.isUserInteractionEnabled = true
            if tagsField.tags.isEmpty { tagsField.placeholder = "Space separated tags" }
            isDoneSwitch.isHidden = false
            stateLabel.text = "mark as done"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                                target: self,
                                                                action: #selector(didTapDone))
        case .viewing:
            titleTextLabel.isUserInteractionEnabled = false
            tagsField.isUserInteractionEnabled = false
            if tagsField.tags.isEmpty { tagsField.placeholder = "No tags were specified" }
            isDoneSwitch.isHidden = true
            stateLabel.text = task!.isDone ? "Marked as done" : "Pending"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(didTapEdit))
        }
    }
    
    @objc func didTapDone() {
        task!.set(name: titleTextLabel.text!)
        task!.set(isDone: isDoneSwitch.isOn)
        task!.set(tagsNames: tagsField.tags.map({ $0.text }))
        self.performSegue(withIdentifier: "unwindToList", sender: self)
    }
    
    @objc func didTapEdit() {
        self.state = .editing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tagsField)
        tagsField.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = tagsField.topAnchor.constraint(equalTo: tagsLabel!.bottomAnchor, constant: 5)
        let leadingConstraint = tagsField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        let trailingConstraint = tagsField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20)
        view.addConstraints([topConstraint, leadingConstraint, trailingConstraint])
        
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagsField.spaceBetweenLines = 5.0
        tagsField.spaceBetweenTags = 10.0
        tagsField.font = .systemFont(ofSize: 19, weight: .light)
        tagsField.backgroundColor = .white
        tagsField.placeholder = "Space separated tags"
        tagsField.tintColor = view.tintColor
        tagsField.textColor = .white
        tagsField.fieldTextColor = .black
        tagsField.selectedColor = .darkGray
        tagsField.selectedTextColor = .white
        tagsField.isDelimiterVisible = false
        tagsField.placeholderColor = .darkGray
        tagsField.placeholderAlwaysVisible = false
        tagsField.returnKeyType = .next
        tagsField.acceptTagOption = .space
    }
    
}
