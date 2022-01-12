//
//  Properties.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 12.03.21.
//

import Foundation

private struct Keys { // make enum
    static let subscriber = "subscriberKey"
    static let skipOnboarding = "skipOnboardingKey"
    static let workoutTimer = "workoutTimer"
    
    static let userGoalSteps = "userGoalSteps"
    static let userGoalCalories = "userGoalCalories"
    
    static let userPersonalData = "userPersonalData"
    static let userWorkouts = "userWorkouts"
    static let currentWorkout = "currentWorkout"
    static let userMetricSystem = "userMetricSystem"
}

class PropertiesService {
    
    let storage = UserDefaults.standard
    
    var subscriber: Bool {
        get { storage.bool(forKey: Keys.subscriber) }
        set { storage.set(newValue, forKey: Keys.subscriber) }
    }
    
    var skipOnboarding: Bool {
        get { storage.bool(forKey: Keys.skipOnboarding) }
        set { storage.set(newValue, forKey: Keys.skipOnboarding) }
    }
    
    var workoutTimer: Bool {
        get { storage.string(forKey: Keys.workoutTimer) != "disabled" }
        set { storage.set(newValue ? nil: "disabled", forKey: Keys.workoutTimer) }
    }
    
    var userGoalSteps: Int {
        get { storage.integer(forKey: Keys.userGoalSteps) }
        set { storage.set(newValue, forKey: Keys.userGoalSteps) }
    }
    
    var userGoalCalories: Int {
        get { storage.integer(forKey: Keys.userGoalCalories) }
        set { storage.set(newValue, forKey: Keys.userGoalCalories) }
    }
    
    var userMetricSystem: MetricSystem {
        get { MetricSystem(rawValue: storage.integer(forKey: Keys.userMetricSystem))! }
        set { storage.set(newValue.rawValue, forKey: Keys.userMetricSystem) }
    }
    
    var userWorkouts: [UserWorkout] {
        get { getValue(key: Keys.userWorkouts) ?? [] }
        set { setValue(newValue, key: Keys.userWorkouts) }
    }
    
    var currentWorkout: UserWorkout? {
        get { getValue(key: Keys.currentWorkout)}
        set { setValue(newValue, key: Keys.currentWorkout) }
    }
    
    var userPersonalData: UserPersonalData {
        get {
            let value: UserPersonalData? = getValue(key: Keys.userPersonalData)
            return value ?? UserPersonalData()
        }
        set {
            setValue(newValue, key: Keys.userPersonalData)
        }
    }
    
    func synchronize() {
        storage.synchronize()
    }
}

private protocol CodableStorage {
    func getValue<Type: Decodable>(key: String) -> Type?
    func setValue<Type: Encodable>(_ value: Type, key: String)
}

extension PropertiesService: CodableStorage {
    func getValue<Type>(key: String) -> Type? where Type: Decodable {
        if let data = storage.data(forKey: key) {
           return try? JSONDecoder().decode(Type.self, from: data)
        }
        return nil
    }
    
    func setValue<Type>(_ value: Type, key: String) where Type: Encodable {
        if let data = try? JSONEncoder().encode(value) {
            storage.set(data, forKey: key)
        }
    }
}
