//
//  MetricSystem.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 31.05.21.
//

import Foundation

enum MetricSystem: Int, Codable, CaseIterable {
    case metric = 0
    case imperial
    
    var title: String {
        switch self {
        case .metric:
            return "Metric"
        case .imperial:
            return "Imperial"
        }
    }
}
