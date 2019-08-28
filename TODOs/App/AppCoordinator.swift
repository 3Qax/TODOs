//
//  AppCoordinator.swift
//  TODOs
//
//  Created by Jakub Towarek on 27/08/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

class AppCoordinator {

    private let window: UIWindow
    private var navigationController: UINavigationController?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let viewController = MenuViewController(delegate: self)
        navigationController = UINavigationController(rootViewController: viewController as UIViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension AppCoordinator: MenuViewControllerDelegate {

    func didTap(list: List) {
        let viewController = ListViewController(list: list, allowsAddingAndEnteringDetails: true, delegate: self)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func didTap(tag: Tag) {
        let list = List.generateFakeList(for: tag)
        let viewController = ListViewController(list: list, allowsAddingAndEnteringDetails: false, delegate: self)
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension AppCoordinator: ListViewControllerDelegate {
    func didRequestedToEnterDetails(for todo: Todo) {
        let viewController = TodoViewController(todo: todo, delegate: self)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func didTapAddNewTodoTo(list: List) {
        let newTodo = Todo(context: AppDelegate.viewContext)
        newTodo.list = list
        let viewController = TodoViewController(todo: newTodo, delegate: self)
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension AppCoordinator: TodoViewControllerDelegate {

    func didSave() {
        navigationController?.popViewController(animated: true)
    }

}
