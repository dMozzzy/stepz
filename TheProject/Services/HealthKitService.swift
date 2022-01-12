//
//  HealthKitService.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 11.05.21.
//

import Foundation
import HealthKit


class HealthKitService {
    
    let queue = DispatchQueue(label: "HealthKitService", qos: .userInitiated)
    
    let storage: PropertiesService
    
    var calendar = Calendar.current
    
    init(storage: PropertiesService) {
        self.storage = storage
    }
    
    func authorize(completion: @escaping (Bool) -> ()) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let stepsType = HKSampleType.quantityType(forIdentifier: .stepCount),
                let flightsType = HKSampleType.quantityType(forIdentifier: .flightsClimbed),
                let exerciseTime = HKSampleType.quantityType(forIdentifier: .appleExerciseTime),
                let distanceType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            
            completion(false)
            return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        stepsType,
                                                        distanceType,
                                                        activeEnergy,
                                                        .workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       stepsType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       distanceType,
                                                       flightsType,
                                                       exerciseTime,
                                                       .activitySummaryType(),
                                                       .workoutType()]

        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func saveWorkout(_ workout: UserWorkout, completion: @escaping (Bool) -> Void) {
        queue.async {
            self.syncSaveWorkout(workout)
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    private func syncSaveWorkout(_ workout: UserWorkout) {
        guard let workoutStart = workout.start, let workoutEnd = workout.end else { return }
       
        let store = HKHealthStore()
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .walking
        
        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        
        let group = DispatchGroup()
        
        group.enter()
        builder.beginCollection(withStart: workoutStart) { success, error in
            assert(success)
            group.leave()
        }
        group.wait()
        
        let samples = getSamples(workout: workout)
        
        group.enter()
        builder.add(samples) { success, error in
            assert(success)
            group.leave()
        }
        group.wait()
        
        group.enter()
        builder.endCollection(withEnd: workoutEnd) { success, error in
            assert(success)
            group.leave()
        }
        group.wait()
        
        group.enter()
        builder.finishWorkout { workout, error in
            assert(error == nil)
            group.leave()
        }
        group.wait()
    }
    
    private func getSamples(workout: UserWorkout) -> [HKSample] {
        guard let stepsType = HKSampleType.quantityType(forIdentifier: .stepCount),
              let distanceType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning),
              let caloriesType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)
        else {
            assertionFailure()
              return []
        }
        
        let stepsSamples: [HKSample] = workout.intervals.map { interval in
            let steps = HKQuantity(unit: .count(), doubleValue: Double(interval.steps))
            return HKQuantitySample(type: stepsType, quantity: steps, start: interval.start, end: interval.end)
        }
        
        let distanceSamples: [HKSample] = workout.intervals.map { interval in
            let distance = HKQuantity(unit: HKUnit(from: .meter), doubleValue: Double(interval.distance))
            return HKQuantitySample(type: distanceType, quantity: distance, start: interval.start, end: interval.end)
        }
        
        let caloriesSamples: [HKSample] = workout.intervals.map { interval in
            let distance = HKQuantity(unit: .kilocalorie(), doubleValue: Double(interval.calories))
            return HKQuantitySample(type: caloriesType, quantity: distance, start: interval.start, end: interval.end)
        }
        
        return stepsSamples + caloriesSamples + distanceSamples
    }
    
    func synchronizePersonalData(completion: (() -> ())? = nil) {
        fetchPersonalData { data in
            if let data = data {
                self.storage.userPersonalData = data
                self.storage.synchronize()
            }
            completion?()
        }
    }
    
    func fetchPersonalData(completion: @escaping (UserPersonalData?) -> Void) {
        let store = HKHealthStore()
        
        let birthday = try? store.dateOfBirthComponents().date
        let sex = try? store.biologicalSex().biologicalSex
        
        var height: Double? //meters
        var bodyMass: Double? // kilograms
        var index: Double?
        
        let group = DispatchGroup()
        
        if let heightType = HKSampleType.quantityType(forIdentifier: .height) {
            group.enter()
            getRecentData(type: heightType) { sample, error in
                height = sample?.quantity.doubleValue(for: HKUnit.meter())
                group.leave()
            }
        }
        
        if let bodyMassType = HKSampleType.quantityType(forIdentifier: .bodyMass) {
            group.enter()
            getRecentData(type: bodyMassType) { sample, error in
                bodyMass = sample?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                group.leave()
            }
        }
        
        if let bodyMassIndexType = HKSampleType.quantityType(forIdentifier: .bodyMassIndex) {
            group.enter()
            getRecentData(type: bodyMassIndexType) { sample, error in
                index = sample?.quantity.doubleValue(for: HKUnit.count())
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            guard let birthday = birthday,
                  let sex = sex,
                  let height = height,
                  let bodyMass = bodyMass else {
                completion(nil)
                return
            }
            let userData = UserPersonalData(dateOfBirth: birthday,
                                            bodyMassIndex: index ?? (bodyMass/(height*height)),
                                            height: height,
                                            bodyMass: bodyMass,
                                            sex: UserSex(sex: sex))
            completion(userData)
        }
        
        
    }
    
    private func getRecentData(type: HKSampleType, completion: @escaping (HKQuantitySample?, Error?) -> Void) {
        let limit = 1
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let descriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit,sortDescriptors: [descriptor])
        { (query, samples, error) in
            if let mostRecentSample = samples?.first as? HKQuantitySample {
                completion(mostRecentSample, nil)
            } else {
                completion(nil, error)
            }
        }
        HKHealthStore().execute(sampleQuery)
    }
}


// MARK: - User activity
extension HealthKitService {
    
    private func queryData(start: Date, end: Date, type: HKQuantityTypeIdentifier, completion: @escaping (HKQuantity?) -> Void) {
        
        let store = HKHealthStore()
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: type) else {
            assertionFailure()
            completion(nil)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) {
            (query, stats, error) in
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let quantity = stats?.sumQuantity() {
                DispatchQueue.main.async {
                    completion(quantity)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        store.execute(query)
    }
    
    @discardableResult
    func queryYearData(year: Int, type: HKQuantityTypeIdentifier, completion: @escaping ([Int: Interval]) -> Void) -> [(start: Date, end: Date)] {
        calendar.timeZone = .current
        
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.year = -year
        components.month = -(components.month ?? 0) + 1
        components.day = -(components.day ?? 0) + 1
        
        let startDate = calendar.date(byAdding: components, to: Date())!
        
        let dayStart = calendar.startOfDay(for: startDate)
        
        let range = calendar.range(of: .month, in: .year, for: dayStart)!
        let daysCount = range.count
        
        let dates: [(start: Date, end: Date)] = (0...daysCount).map { value in
            var start = DateComponents()
            start.month = value
            
            var end = DateComponents()
            end.month = value + 1
            return (calendar.date(byAdding: start, to: dayStart)!, calendar.date(byAdding: end, to: dayStart)!)
        }
        
        var dataset = [Int: Interval]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, date in
            group.enter()
            queryData(start: date.start, end: date.end, type: type) { [index] data in
                let result = data?.doubleValue(for: getUnits(for: type)) ?? 0
                dataset[index] = Interval(start: date.start, end: date.end, value: result)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return dates
    }
    
    @discardableResult
    func queryMonthData(month: Int, type: HKQuantityTypeIdentifier, completion: @escaping ([Int: Interval]) -> Void) -> [(start: Date, end: Date)] {
        calendar.timeZone = .current
        
        var components = calendar.dateComponents([.month, .day], from: Date())
        components.month = -month
        // One day offset for some reason??
        components.day = -(components.day ?? 0) + 1
        
        let startDate = calendar.date(byAdding: components, to: Date())!
        
        let dayStart = calendar.startOfDay(for: startDate)
        
        let range = calendar.range(of: .day, in: .month, for: dayStart)!
        let daysCount = range.count
        
        let dates: [(start: Date, end: Date)] = (0...daysCount - 1).map { value in
            var start = DateComponents()
            start.day = value
            
            var end = DateComponents()
            end.day = value + 1
            return (calendar.date(byAdding: start, to: dayStart)!, calendar.date(byAdding: end, to: dayStart)!)
        }
        
        var dataset = [Int: Interval]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, date in
            group.enter()
            queryData(start: date.start, end: date.end, type: type) { [index] data in
                let result = data?.doubleValue(for: getUnits(for: type)) ?? 0
                dataset[index] = Interval(start: date.start, end: date.end, value: result)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return dates
    }
    
    @discardableResult
    func queryWeekData(week: Int, type: HKQuantityTypeIdentifier, completion: @escaping ([Int: Interval]) -> Void) -> [(start: Date, end: Date)] {
        calendar.timeZone = .current
        
        var components = calendar.dateComponents([.weekOfYear, .weekday], from: Date())
        components.weekOfYear = -week
        components.weekday = -(components.weekday ?? 0) + 1
        
        let dayStart = calendar.startOfDay(for: calendar.date(byAdding: components, to: Date())!)
        
        let dates: [(start: Date, end: Date)] = (0...6).map { value in
            var start = DateComponents()
            start.day = value
            
            var end = DateComponents()
            end.day = value + 1
            return (calendar.date(byAdding: start, to: dayStart)!, calendar.date(byAdding: end, to: dayStart)!)
        }
        
        var dataset = [Int: Interval]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, date in
            group.enter()
            queryData(start: date.start, end: date.end, type: type) { [index] data in
                let result = data?.doubleValue(for: getUnits(for: type)) ?? 0
                dataset[index] = Interval(start: date.start, end: date.end, value: result)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return dates
    }
    
    @discardableResult
    func queryDayData(day: Int, type: HKQuantityTypeIdentifier, completion: @escaping ([Int: Interval]) -> Void) -> [(start: Date, end: Date)] {
        calendar.timeZone = .current
        
        var week = DateComponents()
        week.day = -day
        
        let dayStart = calendar.startOfDay(for: calendar.date(byAdding: week, to: Date())!)
        
        let dates: [(start: Date, end: Date)] = (0...23).map { value in
            var start = DateComponents()
            start.hour = value
            
            var end = DateComponents()
            end.hour = value + 1
            return (calendar.date(byAdding: start, to: dayStart)!, calendar.date(byAdding: end, to: dayStart)!)
        }
        
        var dataset = [Int: Interval]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, date in
            group.enter()
            queryData(start: date.start, end: date.end, type: type) { [index] data in
                let result = data?.doubleValue(for: getUnits(for: type)) ?? 0
                dataset[index] = Interval(start: date.start, end: date.end, value: result)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return dates
    }
}

private func getUnits(for type: HKQuantityTypeIdentifier) -> HKUnit {
    if type == .distanceWalkingRunning {
        return .meter()
    } else if type == .appleExerciseTime {
        return .minute()
    } else {
        return .count()
    }
}
