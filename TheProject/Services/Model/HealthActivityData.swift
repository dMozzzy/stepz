//
//  HealthActivityData.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 17.09.21.
//

import Foundation

struct Interval {
    var start: Date
    var end: Date
    var value: Double
    init(start: Date, end: Date, value: Double) {
        self.start = start
        self.end = end
        self.value = value
    }
}

class HealthActivityData {
    
    var intervals: [Interval] = []
    var type: UserActivityService.ActivityType
    
    var start: Date? {
        intervals.first?.start
    }
    var end: Date? {
        intervals.last?.end
    }
    
    var total: Double {
        let totalSteps = intervals.reduce(0.0) { (result, interval) -> Double in
            result + interval.value
        }
        return totalSteps
    }
    
    var roundedTotal: Double {
        ceil(total)
    }
    
    
    var calories: Double {
        let caloriesPerStep = 0.035
        return total * caloriesPerStep
    }
    
    init(type: UserActivityService.ActivityType, intervals: [Interval] = []) {
        self.type = type
        self.intervals = intervals
    }
}

extension Interval {
  var calories: Double {
    let caloriesPerStep = 0.035
    return value * caloriesPerStep
  }
}
