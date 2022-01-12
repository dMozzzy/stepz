//
//  ViewControllerBuilder.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 15.03.21.
//

import UIKit

private struct Storyboards {
    static let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
    static let workout = UIStoryboard(name: "Workout", bundle: nil)
    static let main = UIStoryboard(name: "Main", bundle: nil)
    static let root = UIStoryboard(name: "Root", bundle: nil)
}

class ViewControllerBuilder {
    
    func buildWelcomeController() -> WelcomeViewController {
        Storyboards.onboarding.instantiateViewController(identifier: "WelcomeViewController")
    }
    
    func buildHealthKitController() -> HealthKitViewController {
        Storyboards.onboarding.instantiateViewController(identifier: "HealthKitViewController")
    }
    
    func buildRootNavigationController() -> RootNavigationController {
        Storyboards.root.instantiateViewController(identifier: "RootNavigationController")
    }
    
    func buildNoPermissionController() -> NoPermissionViewController {
        Storyboards.root.instantiateViewController(identifier: "NoPermissionViewController")
    }
    
    
    func buildOnboardingProfileViewController() -> OnboardingProfileViewController {
        Storyboards.onboarding.instantiateViewController(identifier: "OnboardingProfileViewController")
    }
    
    func buildTermsViewController() -> TermsViewController {
        Storyboards.onboarding.instantiateViewController(identifier: "TermsViewController")
    }
    

}
