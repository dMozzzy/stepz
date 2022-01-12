//
//  UserActivityService.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 10.04.21.
//

import Foundation
import CoreMotion
import HealthKit

extension UserActivityService {
    enum ActivityType {
        case steps
        case calories
        case distance
        case workoutTime
        case flights
        
        var HKType: HKQuantityTypeIdentifier {
            switch self {
            case .steps:
                return .stepCount
            case .calories:
                return .stepCount
            case .distance:
                return .distanceWalkingRunning
            case .workoutTime:
                return .appleExerciseTime
            case .flights:
                return .flightsClimbed
            }
        }
    }
}

class UserActivityService {
    
    var workouts: [UserWorkout] {
        properties.userWorkouts
    }
    
    private let queue = DispatchQueue(label: "UserActivityService", qos: .userInitiated)
    
    private let health: HealthKitService
    private let pedometer: PedometerService
    private let properties: PropertiesService
    
    var goals: UserGoals {
        set {
            properties.userGoalSteps = newValue.steps
            properties.userGoalCalories = newValue.calories
        }
        get {
            let userGoalSteps = properties.userGoalSteps
            let userGoalCalories = properties.userGoalCalories
            return UserGoals(steps: userGoalSteps == 0 ? 8000: userGoalSteps, calories: userGoalCalories == 0 ? 1000: userGoalCalories)
        }
    }
    
    var emptyActivity: UserActivityData {
        UserActivityData(goals: self.goals, today: CMPedometerData(), week: CMPedometerData())
    }
    
    init(locator: ServiceLocator = Services.locator) {
        self.pedometer = locator.pedometer
        self.properties = locator.properties
        self.health = locator.healthKit
    }
    
    func queryActivity(completion: @escaping (UserActivityData?) -> Void) {
        queue.async {
            let group = DispatchGroup()
            
            var week: CMPedometerData?
            var day: CMPedometerData?
            
            group.enter()
            self.pedometer.queryWeekData { data in
                week = data
                group.leave()
            }
            
            group.enter()
            self.pedometer.queryTodayData { data in
                day = data
                group.leave()
            }
            
            group.notify(queue: .main) {
                var activity: UserActivityData?
                if let week = week, let day = day {
                    activity = UserActivityData(goals: self.goals, today: day, week: week)
                }
                completion(activity)
            }
        }
    }
    
    func queryHealthKitActivity(period: InsightsPeriod, type: ActivityType, completion: @escaping (HealthActivityData) -> Void) -> [(start: Date, end: Date)] {
        switch period.length {
        case .day:
            return health.queryDayData(day: period.offset, type: type.HKType) { dataset in
                let activity = processDataset(dataset, type: type)
                completion(activity)
            }
        case .week:
            return health.queryWeekData(week: period.offset, type: type.HKType) { dataset in
                let activity = processDataset(dataset, type: type)
                completion(activity)
            }
        case .month:
            return health.queryMonthData(month: period.offset, type: type.HKType) { dataset in
                let activity = processDataset(dataset, type: type)
                completion(activity)
            }
        case .year:
            return health.queryYearData(year: period.offset, type: type.HKType) { dataset in
                let activity = processDataset(dataset, type: type)
                completion(activity)
            }
        }

    }
    
    /// Pedometer data. Contains data only for last 7 days. Obsolete!
    func queryActivity(period: InsightsPeriod, completion: @escaping (UserWorkout) -> Void) -> Date {
        switch period.length {
        case .day:
            return pedometer.queryDetailedData(day: period.offset) { dataset in
                let activity = processDataset(dataset)
                completion(activity)
            }
        case .week:
            return pedometer.queryDetailedData(week: period.offset) { dataset in
                let activity = processDataset(dataset)
                completion(activity)
            }
        case .month:
            return pedometer.queryDetailedData(month: period.offset) { dataset in
                let activity = processDataset(dataset)
                completion(activity)
            }
        case .year:
            return pedometer.queryDetailedData(year: period.offset) { dataset in
                let activity = processDataset(dataset)
                completion(activity)
            }
        }
    }
    
    func saveWorkout(_ workout: UserWorkout) {
        var workouts = self.workouts
        workouts.append(workout)
        properties.userWorkouts = workouts
        properties.synchronize()
    }
    
    func removeWorkout(_ workout: UserWorkout) {
        var workouts = self.workouts
        workouts.removeAll { $0.id == workout.id }
        properties.userWorkouts = workouts
        properties.synchronize()
    }
    
}


private func processDataset(_ dataset: [Int: CMPedometerData]) -> UserWorkout {
    var values: [CMPedometerData] = []
    dataset.keys.sorted().forEach { index in
        values.append(dataset[index]!)
    }
    return UserWorkout(dataSet: values)
}

private func processDataset(_ dataset: [Int: Interval], type: UserActivityService.ActivityType) -> HealthActivityData {
    var values: [Interval] = []
    dataset.keys.sorted().forEach { index in
        values.append(dataset[index]!)
    }
    return HealthActivityData(type: type, intervals: values)
}
