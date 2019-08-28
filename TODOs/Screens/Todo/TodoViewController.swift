//
//  TodoViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 13/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData
import WSTagsField

protocol TodoViewControllerDelegate: AnyObject {
    func didSave()
}

final class TodoViewController: UIViewController {

    private var customView: TodoView { return self.view as! TodoView }
    private var saveBarButtonItem: UIBarButtonItem?
    private weak var delegate: TodoViewControllerDelegate?
    private var todo: Todo

    init(todo: Todo, delegate: TodoViewControllerDelegate? = nil) {
        self.todo = todo
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = TodoView.instanceFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                 target: self,
                                                 action: #selector(didTapSaveButton))
        navigationItem.rightBarButtonItem = saveBarButtonItem
        navigationItem.hidesBackButton = true

        customView.tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        customView.tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        customView.tagsField.spaceBetweenLines = 5.0
        customView.tagsField.spaceBetweenTags = 10.0
        customView.tagsField.font = .systemFont(ofSize: 19, weight: .light)
        customView.tagsField.backgroundColor = .white
        customView.tagsField.placeholder = "No tags entered...."
        customView.tagsField.tintColor = view.tintColor
        customView.tagsField.textColor = .white
        customView.tagsField.fieldTextColor = .black
        customView.tagsField.selectedColor = .darkGray
        customView.tagsField.selectedTextColor = .white
        customView.tagsField.isDelimiterVisible = false
        customView.tagsField.placeholderColor = .lightGray
        customView.tagsField.placeholderAlwaysVisible = false
        customView.tagsField.returnKeyType = .next
        customView.tagsField.acceptTagOption = .space
    }

    override func viewWillAppear(_ animated: Bool) {
        customView.titleTextView.text = todo.name
        customView.isDoneSwitch.isOn = todo.isDone
    }

    @objc func didTapSaveButton() {
        todo.name = customView.titleTextView.text!
        todo.isDone = customView.isDoneSwitch.isOn
        todo.set(tagsNames: customView.tagsField.tags.map({ $0.text }))
        do {
            try AppDelegate.viewContext.save()
            delegate?.didSave()
        } catch let error {
            print("Can not save: \(error.localizedDescription)")
        }

    }

}
