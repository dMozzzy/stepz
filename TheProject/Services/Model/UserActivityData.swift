//
//  ActivityData.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 6.04.21.
//

import Foundation
import CoreMotion

struct UserActivityData {
    let goals: UserGoals
    let today: CMPedometerData
    let week: CMPedometerData
}
