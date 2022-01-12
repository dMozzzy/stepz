//
//  UserWorkout.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 20.04.21.
//

import Foundation
import CoreMotion

class UserWorkout: Codable {
    
    var id = UUID().uuidString
    
    class Interval: Codable {
        
        var start: Date
        var end: Date
        
        var steps: Int = 0
        
        var floors: Int = 0
        
        var calories: Double {
            let caloriesPerStep = 0.035
            return Double(steps) * caloriesPerStep
        }
        
        var duration: TimeInterval {
            abs(start.timeIntervalSince(end))
        }
        
        /// In Meters
        var distance: Double = 0.0
        
        /// Seconds per meter
        var avgPace: Double = 0.0
        
        init(start: Date) {
            self.start = start
            self.end = start
        }
        
        init(start: Date, end: Date, steps: Int) {
            self.start = start
            self.end = end
            
            self.steps = steps
        }
        
        init(data: CMPedometerData) {
            self.start = data.startDate
            self.end = data.endDate
            update(data)
        }
        
        func update(_ data: CMPedometerData) {
            steps = data.numberOfSteps.intValue
            distance = data.distance?.doubleValue ?? 0.0
            avgPace = data.averageActivePace?.doubleValue ?? 0.0
            floors = data.floorsAscended?.intValue ?? 0
        }
        
    }
    
    var intervals: [Interval] = []
    
    var start: Date? {
        intervals.first?.start
    }
    var end: Date? {
        intervals.last?.end
    }
    
    var duration: TimeInterval {
        let totalDuration = intervals.reduce(0) { (result, interval) -> TimeInterval in
            result + abs(interval.start.timeIntervalSince(interval.end))
        }
        return totalDuration
    }
    
    var steps: Int {
        let totalSteps = intervals.reduce(0) { (result, interval) -> Int in
            result + interval.steps
        }
        return totalSteps
    }
    
    var floors: Int {
        let totalFloors = intervals.reduce(0) { (result, interval) -> Int in
            result + interval.floors
        }
        return totalFloors
    }
    
    var calories: Double {
        let caloriesPerStep = 0.035
        return Double(steps) * caloriesPerStep
    }
    
    /// In Meters
    var distance: Double {
        let totalDistance = intervals.reduce(0.0) { (result, interval) -> Double in
            result + interval.distance
        }
        return totalDistance
    }
    
    /// Seconds per meter
    var avgPace: Double {
        let totalPace = intervals.reduce(0.0) { (result, interval) -> Double in
            result + interval.avgPace
        }
        return totalPace / Double(intervals.count)
    }
    
    init(intervals: [Interval]) {
        self.intervals = intervals
    }
    
    init() { }
    
    convenience init(dataSet: [CMPedometerData]) {
        let intervals: [Interval] = dataSet.map { Interval(data: $0) }
        self.init(intervals: intervals)
    }
    
}


extension UserWorkout {
    func formattedTime() -> String {
        let formatter =  DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm:ss"
        let date = Date(timeIntervalSince1970: duration)
        return formatter.string(from: date)
    }
}
