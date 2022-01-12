//
//  UserPersonalData.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 11.05.21.
//

import Foundation
import HealthKit

struct UserPersonalData: Codable {
    var dateOfBirth: Date = Date(timeIntervalSinceReferenceDate: 0)
    var bodyMassIndex: Double = 25
    var height: Double = 180
    var bodyMass: Double = 60
    var sex: UserSex = .unknown
}


enum UserSex: Int, Codable, CaseIterable {
    case unknown
    case male
    case female
    
    init(sex: HKBiologicalSex) {
        switch sex {
        case .female:
            self = .female
        case .male:
            self = .male
        case .notSet,
             .other:
            self = .unknown
        @unknown default:
            assertionFailure("wtf?")
            self = .unknown
        }
    }
    var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
}
