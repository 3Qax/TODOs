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

            let textRangeToSelet = customView.titleTextView.textRange(from: customView.titleTextView.beginningOfDocument,
                                                                      to: customView.titleTextView.beginningOfDocument)
            customView.titleTextView.selectedTextRange = textRangeToSelet
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

        // setup initial values for selectedTextRange of textViews,
        // so that when user taps them first tim textViewDidChangeSelection() will get trigerred
        let textViews: [UITextView] = [customView.titleTextView, customView.tagsTextView]
        for textView in textViews {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument,
                                                            to: textView.beginningOfDocument)
        }

        customView.titleTextView.becomeFirstResponder()

    }

    @objc private func didTapSaveButton() {

        // make sure that user specified title
        // due to placeholder implemenatation if title is empty, textView.text will be equal to placeholder
        guard customView.titleTextView.text != titleTextViewPlaceholer else {
            // if user doesn't specify title show alert letting user either enter it or cancle adding/editing todo
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

        // make sure to not treat placeholder text as actual tags, due to placeholder implemantation
        if customView.tagsTextView.text == tagsTextViewPlaceholder { todo.assign(tags: [String]())
        } else { todo.assign(tags: customView.tagsTextView.text.components(separatedBy: " ")) }

        // try to save the context
        // FIXME: extract this to a model function
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

// This extension handles fake placeholders for titleTextView and tagsTextView
extension TodoViewController: UITextViewDelegate {

    func textViewDidChangeSelection(_ textView: UITextView) {

        // make sure that the view is visible
        if self.view.window != nil {

            // if there is placeholder in any of textViews force curosr to be always at the beginning
            if textView === customView.titleTextView && textView.text == titleTextViewPlaceholer
            || textView === customView.tagsTextView && textView.text == tagsTextViewPlaceholder {

                // move cursor to the beginning of the textview
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument,
                                                                to: textView.beginningOfDocument)

            }

        }

    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // textView's current text (without any modifications)
        let currentText: String = textView.text

        // what will text of textView look like after applying changes
        // (Combining the textView current text and the replacement text)
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // if the textView is going to be empty, insert placeholder text and style it appropreatly
        if updatedText.isEmpty {

            if textView === customView.titleTextView { textView.text = titleTextViewPlaceholer }
            if textView === customView.tagsTextView { textView.text = tagsTextViewPlaceholder }
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument,
                                                            to: textView.beginningOfDocument)

            // since placeholder text has been set manually, doesn't allow textView to change it
            return false

        }

        // if the textView won't be empty,
        // but there is placeholder in it and the change is not a deletion
        if textView.textColor == UIColor.lightGray && !text.isEmpty {

            // delete placeholder text and remove placeholder styling
            textView.textColor = .black
            textView.text = ""

            // let the textView insert replacement text
            return true

        }

        // for every other case, the textView should use it's normal behavior
        return true

    }

}
