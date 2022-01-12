//
//  RootCoordinator.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 15.03.21.
//

import UIKit

class RootCoordinator: BaseCoordinator {
    
    override func start() {
        presentOnboarding()
    }
    
    private func presentOnboarding() {
        let coordinator = OnboardingCoordinator(navigationController: navigationController)
        coordinator.parent = self
        presentCoordinator(coordinator)
    }
    
    private func presentCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

extension RootCoordinator: OnboardingCoordinatorParent {
    func onboardingDone() {
        presentOnboarding()
    }
}
