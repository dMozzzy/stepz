//
//  PedometerService.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 28.03.21.
//

import CoreMotion

class PedometerService {
    let pedometer = CMPedometer()
    
    var calendar = Calendar.current
    
    var status: CMAuthorizationStatus {
        CMPedometer.authorizationStatus()
    }
    
    var isAuthorized: Bool {
        CMPedometer.authorizationStatus() == .authorized
    }
    
    init() {
        self.calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }
    
    func requestPermission(completion: @escaping (CMAuthorizationStatus) -> Void) {
        guard CMPedometer.authorizationStatus() == .notDetermined else {
            DispatchQueue.main.async {
                completion(CMPedometer.authorizationStatus())
            }
            return
        }
        pedometer.queryPedometerData(from: Date(), to: Date()) { (_, _) in
            DispatchQueue.main.async {
                completion(CMPedometer.authorizationStatus())
            }
        }
    }
    
    func queryData(start: Date, end: Date, completion: @escaping (CMPedometerData?) -> Void) {
        guard isAuthorized else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        pedometer.queryPedometerData(from: start, to: end) { (data, error) in
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }
    
    func queryTodayData(completion: @escaping (CMPedometerData?) -> Void) {
        let end = Date()
        let start = calendar.startOfDay(for: end)

        queryData(start: start, end: end, completion: completion)
    }
    
    func queryWeekData(completion: @escaping (CMPedometerData?) -> Void) {
        let now = Date()
        var week = DateComponents()
        week.day = -7
        
        guard let lastWeek = calendar.date(byAdding: week, to: now) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        let start = calendar.startOfDay(for: lastWeek)
        
        queryData(start: start, end: now, completion: completion)
    }
    
    func queryYesterdayData(completion: @escaping (CMPedometerData?) -> Void) {
        let end = calendar.startOfDay(for: Date())
        var week = DateComponents()
        week.day = -1
        
        guard let lastWeek = calendar.date(byAdding: week, to: Date()) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        let start = calendar.startOfDay(for: lastWeek)
        
        queryData(start: start, end: end, completion: completion)
    }
    
    func queryDetailedData(year: Int, completion: @escaping ([Int: CMPedometerData]) -> Void) -> Date {
        calendar.timeZone = .current
        
        var components = calendar.dateComponents([.year], from: Date())
        components.year = -year
        
        let startDate = calendar.date(byAdding: components, to: Date())!
        
        let dayStart = calendar.startOfDay(for: startDate)
        
        let range = calendar.range(of: .month, in: .year, for: dayStart)!
        let daysCount = range.count
        
        let dates: [(start: Date, end: Date)] = (0...daysCount).map { value in
            var start = DateComponents()
            start.day = value
            
            var end = DateComponents()
            end.day = value + 1
            return (calendar.date(byAdding: start, to: dayStart)!, calendar.date(byAdding: end, to: dayStart)!)
        }
        
        var dataset = [Int: CMPedometerData]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, dates in
            group.enter()
            queryData(start: dates.start, end: dates.end) { [index] data in
                dataset[index] = data
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return startDate
    }
    
    func queryDetailedData(month: Int, completion: @escaping ([Int: CMPedometerData]) -> Void) -> Date {
        calendar.timeZone = .current
        
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.month = -month
        
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
        
        var dataset = [Int: CMPedometerData]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, dates in
            group.enter()
            queryData(start: dates.start, end: dates.end) { [index] data in
                dataset[index] = data
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return startDate
    }
    
    func queryDetailedData(week: Int, completion: @escaping ([Int: CMPedometerData]) -> Void) -> Date {
        calendar.timeZone = .current
        
        var components = DateComponents()
        components.day = -(week + 1) * 7
        
        let dayStart = calendar.startOfDay(for: calendar.date(byAdding: components, to: Date())!)
        
        let dates: [(start: Date, end: Date)] = (0...6).map { value in
            var start = DateComponents()
            start.day = value
            
            var end = DateComponents()
            end.day = value + 1
            return (calendar.date(byAdding: start, to: dayStart)!, calendar.date(byAdding: end, to: dayStart)!)
        }
        
        var dataset = [Int: CMPedometerData]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, dates in
            group.enter()
            queryData(start: dates.start, end: dates.end) { [index] data in
                dataset[index] = data
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return dayStart
    }
    
    @discardableResult
    func queryDetailedData(day: Int, completion: @escaping ([Int: CMPedometerData]) -> Void) -> Date {
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
        
        var dataset = [Int: CMPedometerData]()
        
        let group = DispatchGroup()
        dates.enumerated().forEach { index, dates in
            group.enter()
            queryData(start: dates.start, end: dates.end) { [index] data in
                dataset[index] = data
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(dataset)
        }
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return dayStart
    }
    
    func startUpdates(handler: @escaping (CMPedometerData?) -> Void) -> Date {
        let startDate = Date()
        pedometer.startUpdates(from: startDate) { data, error in
            #if !targetEnvironment(simulator)
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            #endif
            DispatchQueue.main.async {
                handler(data)
            }
        }
        return startDate
    }
    
    func stop() {
        pedometer.stopUpdates()
    }
    
}
