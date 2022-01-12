//
//  Coordinator.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 15.03.21.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func childDidFinish(_ coordinator: Coordinator)
    func start()
}

class BaseCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    let builder: ViewControllerBuilder
    let properties: PropertiesService
    
    let serviceLocator: ServiceLocator
    
    init(navigationController: UINavigationController, serviceLocator: ServiceLocator = Services.locator) {
        self.navigationController = navigationController
        self.serviceLocator = serviceLocator
        
        self.builder = serviceLocator.builder
        self.properties = serviceLocator.properties
    }
    
    func childDidFinish(_ coordinator: Coordinator) {
        childCoordinators.removeAll { child -> Bool in
            child === coordinator
        }
    }
    func start() { }
}
