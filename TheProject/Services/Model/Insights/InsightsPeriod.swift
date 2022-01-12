//
//  InsightsPeriod.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 23.06.21.
//

import Foundation

enum PeriodLength {
    case day
    case week
    case month
    case year
}

struct InsightsPeriod {
    var length: PeriodLength
    var offset: Int
}
