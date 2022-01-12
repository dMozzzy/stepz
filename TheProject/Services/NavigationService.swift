//
//  Navigation.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 12.03.21.
//

import UIKit

protocol NavigationServiceDelegate: AnyObject {
    func onboardingFinished()
}

class NavigationService {
    
    weak var delegate: NavigationServiceDelegate?
    
    let properties = Services.locator.properties
    
    func onboardingDone() {
        delegate?.onboardingFinished()
    }
    
}


