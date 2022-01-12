//
//  WorkoutCoordinator.swift
//  TheProject
//
//  Created by Victor Privalov on 26.03.21.
//

import UIKit

class WorkoutCoordinator: BaseCoordinator {
    
    var parent: Coordinator?
    lazy var pedometer = serviceLocator.pedometer
    
    var timer: Bool {
        properties.workoutTimer == true && properties.currentWorkout == nil
    }
    
    override init(navigationController: UINavigationController, serviceLocator: ServiceLocator = Services.locator) {
        super.init(navigationController: navigationController, serviceLocator: serviceLocator)
        
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.makeTransparent()
    }
    
    
    override func start() {
        let controller = builder.buildWorkoutController()
        controller.coordinator = self
        if let workout = serviceLocator.properties.currentWorkout {
            
            if let intervalStart = workout.intervals.last?.end {
                let interval = UserWorkout.Interval(start: intervalStart)
                interval.end = Date()
                workout.intervals.append(interval)
            }
            controller.workout = workout
            controller.updateCurrentInterval()
        }
        navigationController.viewControllers = [controller]
    }
    
    func presentWorkoutOverview(_ workout: UserWorkout) {
        let controller = builder.buildWorkoutOverviewController()
        controller.coordinator = self
        controller.workout = workout
        controller.type = .finish
        controller.endWorkoutOverviewHandler = endWorkoutOverview(workout:saveWorkout:)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func endWorkout(_ workout: UserWorkout) {
        properties.currentWorkout = nil
        properties.synchronize()
        presentWorkoutOverview(workout)
    }
    
    func endWorkoutOverview(workout: UserWorkout, saveWorkout: Bool) {
        if saveWorkout {
            serviceLocator.userActivity.saveWorkout(workout)
            serviceLocator.healthKit.saveWorkout(workout) { success in
                assert(success)
            }
        }
        parent?.childDidFinish(self)
    }
    
}

extension WorkoutCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        switch (viewController) {
        case(is WorkoutViewController):
            navigationController.setNavigationBarHidden(true, animated: true)
        case(_):
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }
}


private extension UINavigationBar {
    func makeTransparent() {
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
}
