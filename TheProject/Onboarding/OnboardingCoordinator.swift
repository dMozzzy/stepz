//
//  OnboardingCoordinator.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 16.03.21.
//

import UIKit

protocol OnboardingCoordinatorParent: Coordinator {
    func onboardingDone()
}

class OnboardingCoordinator: BaseCoordinator {
    weak var parent: OnboardingCoordinatorParent?
    
    override func start() {
        let welcomeController = builder.buildWelcomeController()
        welcomeController.coordinator = self
        navigationController.pushViewController(welcomeController, animated: false)
    }
    
    func openTermsController(content: TermsViewController.Content) {
        let controller = builder.buildTermsViewController()
        controller.content = content
        controller.coordinator = self
        navigationController.pushViewController(controller, animated: true)
    }
    
    func termsControllerDone() {
        navigationController.popViewController(animated: true)
    }
    
    func welcomeComplete() {
        serviceLocator.pedometer.requestPermission { status in
            if status == .authorized {
                let billingController = self.builder.buildHealthKitController()
                billingController.coordinator = self
                self.navigationController.pushViewController(billingController, animated: true)
            } else {
                let controller = self.builder.buildNoPermissionController()
                self.navigationController.viewControllers = [controller]
            }
        }
    }
    
    func profileDone() {
        self.parent?.onboardingDone()
        self.parent?.childDidFinish(self)
    }
    
    func healthKitComplete() {
        
        self.serviceLocator.healthKit.authorize { success in
            let controller = self.serviceLocator.builder.buildOnboardingProfileViewController()
            controller.status = success ? .granted: .limited
            controller.coordinator = self
            if success {
                self.serviceLocator.healthKit.synchronizePersonalData() {
                    self.navigationController.pushViewController(controller, animated: true)
                }
            } else {
                self.navigationController.pushViewController(controller, animated: true)
            }
        }
    }
    
}
