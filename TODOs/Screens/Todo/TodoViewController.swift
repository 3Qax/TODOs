//
//  TodoViewController.swift
//  TODOs
//
//  Created by Jakub Towarek on 13/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit
import CoreData

protocol TodoViewControllerDelegate: AnyObject {
    func didSave()
    func didCancel()
}

final class TodoViewController: UIViewController {

    private var customView: TodoView { return self.view as! TodoView }
    private let titleTextViewPlaceholer = "Enter title here"
    private let tagsTextViewPlaceholder = "Enter space separated tags here"
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

        // setup navigation bar and save button
        navigationItem.hidesBackButton = true
        saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                 target: self,
                                                 action: #selector(didTapSaveButton))
        navigationItem.rightBarButtonItem = saveBarButtonItem

        // setup textViews delegates (for handling fake placeholder)
        customView.tagsTextView.delegate = self
        customView.titleTextView.delegate = self

        // set default values for: titleTextView, isDoneSwitch, tagsTextView
        if todo.name.isEmpty {
            customView.titleTextView.textColor = .lightGray
            customView.titleTextView.text = titleTextViewPlaceholer
            navigationItem.title = "Add new todo"
            customView.titleTextView.selectedTextRange = customView.titleTextView.textRange(from: customView.titleTextView.beginningOfDocument,
                                                                                            to: customView.titleTextView.beginningOfDocument)
        } else {
            customView.titleTextView.textColor = .black
            customView.titleTextView.text = todo.name
            navigationItem.title = todo.name
        }

        customView.isDoneSwitch.isOn = todo.isDone

        if todo.tags.isEmpty {
            customView.tagsTextView.textColor = .lightGray
            customView.tagsTextView.text = tagsTextViewPlaceholder
        } else {
            customView.tagsTextView.textColor = .black
            customView.tagsTextView.text = todo.tags.map({ $0.name }).joined(separator: " ")
        }

        customView.titleTextView.becomeFirstResponder()

    }

    @objc private func didTapSaveButton() {

        if customView.titleTextView.text == titleTextViewPlaceholer {
            let alert = UIAlertController(title: "Empty title",
                              message: "Cannot save a TODO that doesn't have a title. Please enter one.",
                              preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I'll provide one", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Exit and delete that todo", style: .destructive, handler: { [weak self] _ in
                self?.delegate?.didCancel()
                if let todo = self?.todo { AppDelegate.viewContext.delete(todo) }
            }))
            self.present(alert, animated: true)
            return
        }
        todo.name = customView.titleTextView.text!
        todo.isDone = customView.isDoneSwitch.isOn
        todo.set(tagsNames: customView.tagsTextView.text.components(separatedBy: " "))
        do {
            try AppDelegate.viewContext.save()
            delegate?.didSave()
        } catch let error {
            let alert = UIAlertController(title: "Something went wrong",
                              message: "Can not save: \(error.localizedDescription)",
                              preferredStyle: .alert)
            self.present(alert, animated: true)
        }

    }

    @objc private func didTapCancleButton() {
        delegate?.didCancel()
    }

}

/// This extension handles fake placeholders for titleTextView and tagsTextView
extension TodoViewController: UITextViewDelegate {

    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView === customView.titleTextView && textView.text == titleTextViewPlaceholer {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument,
                                                                to: textView.beginningOfDocument)
            }
            if textView === customView.tagsTextView && textView.text == tagsTextViewPlaceholder {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument,
                                                                to: textView.beginningOfDocument)
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {

            if textView === customView.titleTextView { textView.text = titleTextViewPlaceholer }
            if textView === customView.tagsTextView { textView.text = tagsTextViewPlaceholder }
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument,
                                                            to: textView.beginningOfDocument)
        }

            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }

            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }

        // ...otherwise return false since the updates have already
        // been made
        return false
    }

}
