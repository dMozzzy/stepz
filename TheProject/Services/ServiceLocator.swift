//
//  ServiceLocator.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 12.03.21.
//

import Foundation

class Services {
    static let locator = ServiceLocator()
}

class ServiceLocator {
    lazy var builder: ViewControllerBuilder = ViewControllerBuilder()
    lazy var properties: PropertiesService = PropertiesService()
    lazy var navigation: NavigationService = NavigationService()
    lazy var pedometer: PedometerService = PedometerService()
    lazy var appState: AppStateService = AppStateService()
    lazy var healthKit: HealthKitService = HealthKitService(storage: properties)
    
    lazy var userActivity: UserActivityService = UserActivityService()
}

