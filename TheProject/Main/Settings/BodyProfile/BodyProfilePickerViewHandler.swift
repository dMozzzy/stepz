//
//  BodyProfilePickerViewHandler.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 5.06.21.
//

import UIKit

class SexPickerViewHandler {
    
    let completion: (UserSex) -> Void
    var selectedValue: UserSex
    
    let handler = PickerViewHandler()
    
    init(selectedValue: UserSex, completion: @escaping (UserSex) -> Void) {
        self.selectedValue = selectedValue
        self.completion = completion
        handler.delegate = self
    }
    
    func buildPickerAlert(size: CGSize) -> UIViewController {
        
        let selectedRow = selectedValue.rawValue
        let controller = handler.buildPickerAlert(size: size, selection: [(row: selectedRow, component: 0)]) { success in
            if success {
                self.completion(self.selectedValue)
            }
        }
        
        return controller
    }
}

extension SexPickerViewHandler: PickerViewHandlerDelegate {
    func numberOfComponents() -> Int {
        1
    }
    
    func numberOfRowsInComponent(_ component: Int) -> Int {
        UserSex.allCases.count
    }
    
    func titleForRow(_ row: Int, component: Int) -> String? {
        let value = UserSex.allCases[row]
        return "\(value)"
    }
    
    func didSelectRow(_ row: Int, component: Int) {
        let value = UserSex.allCases[row]
        selectedValue = value
    }
}


class HeightPickerViewHandler {
    
    let range = 50...250
    let minorRange = 0...9
    
    var valueOffset = 50
    
    let completion: (Double) -> Void
    var selectedValue: Double {
        Double(selectedMainComponent + valueOffset) + Double(selectedMinorComponent) / 10.0
    }
    
    private var selectedMainComponent: Int
    private var selectedMinorComponent: Int
    
    let handler = PickerViewHandler()
    
    init(selectedValue: Double, completion: @escaping (Double) -> Void) {

        selectedMainComponent = Int(selectedValue) - valueOffset
        selectedMinorComponent = Int((selectedValue.truncatingRemainder(dividingBy: 1)) * 10)
        
        selectedMainComponent = max(min(selectedMainComponent, range.last!), range.first!)
        selectedMinorComponent = max(min(selectedMinorComponent, minorRange.last!), minorRange.first!)
        
        self.completion = completion
        handler.delegate = self
    }
    
    func buildPickerAlert(size: CGSize) -> UIViewController {
        
        let selectedMain = selectedMainComponent
        let selectedMinor = selectedMinorComponent
        let controller = handler.buildPickerAlert(size: size, selection: [(row: selectedMain, component: 0), (row: selectedMinor, component: 1)]) { success in
            if success {
                self.completion(self.selectedValue)
            }
        }
        
        return controller
    }
}

extension HeightPickerViewHandler: PickerViewHandlerDelegate {
    func numberOfComponents() -> Int {
        2
    }
    
    func numberOfRowsInComponent(_ component: Int) -> Int {
        switch component {
        case 0:
            return range.count
        case 1:
            return minorRange.count
        default:
            assertionFailure()
            return 0
        }
    }
    
    func titleForRow(_ row: Int, component: Int) -> String? {
        switch component {
        case 0:
            let value = range[range.index(range.startIndex, offsetBy: row)]
            return "\(value)"
        case 1:
            let value = minorRange[minorRange.index(minorRange.startIndex, offsetBy: row)]
            return "\(value)"
        default:
            assertionFailure()
            return ""
        }
    }
    
    func didSelectRow(_ row: Int, component: Int) {
        switch component {
        case 0:
            selectedMainComponent = range[range.index(range.startIndex, offsetBy: row)] - valueOffset
        case 1:
            selectedMinorComponent = minorRange[minorRange.index(minorRange.startIndex, offsetBy: row)]
        default:
            assertionFailure()
        }
    }
}

class WeightPickerViewHandler {
    
    let range = 10...200
    let minorRange = 0...9
    
    var valueOffset = 10
    
    let completion: (Double) -> Void
    var selectedValue: Double {
        Double(selectedMainComponent + valueOffset) + Double(selectedMinorComponent) / 10.0
    }
    
    private var selectedMainComponent: Int
    private var selectedMinorComponent: Int
    
    let handler = PickerViewHandler()
    
    init(selectedValue: Double, completion: @escaping (Double) -> Void) {

        selectedMainComponent = Int(selectedValue) - valueOffset
        selectedMinorComponent = Int((selectedValue.truncatingRemainder(dividingBy: 1)) * 10)
        
        self.completion = completion
        handler.delegate = self
    }
    
    func buildPickerAlert(size: CGSize) -> UIViewController {
        
        let selectedMain = selectedMainComponent
        let selectedMinor = selectedMinorComponent
        let controller = handler.buildPickerAlert(size: size, selection: [(row: selectedMain, component: 0), (row: selectedMinor, component: 1)]) { success in
            if success {
                self.completion(self.selectedValue)
            }
        }
        
        return controller
    }
}

extension WeightPickerViewHandler: PickerViewHandlerDelegate {
    func numberOfComponents() -> Int {
        2
    }
    
    func numberOfRowsInComponent(_ component: Int) -> Int {
        switch component {
        case 0:
            return range.count
        case 1:
            return minorRange.count
        default:
            assertionFailure()
            return 0
        }
    }
    
    func titleForRow(_ row: Int, component: Int) -> String? {
        switch component {
        case 0:
            let value = range[range.index(range.startIndex, offsetBy: row)]
            return "\(value)"
        case 1:
            let value = minorRange[minorRange.index(minorRange.startIndex, offsetBy: row)]
            return "\(value)"
        default:
            assertionFailure()
            return ""
        }
    }
    
    func didSelectRow(_ row: Int, component: Int) {
        switch component {
        case 0:
            selectedMainComponent = range[range.index(range.startIndex, offsetBy: row)] - valueOffset
        case 1:
            selectedMinorComponent = minorRange[minorRange.index(minorRange.startIndex, offsetBy: row)]
        default:
            assertionFailure()
        }
    }
}

class DatePickerViewHandler {
    let completion: (Date) -> Void
    var selectedValue: Date
    
    let handler = PickerViewHandler()
    
    init(selectedValue: Date, completion: @escaping (Date) -> Void) {
        self.selectedValue = selectedValue
        self.completion = completion
    }
    
    func buildPickerAlert(size: CGSize) -> UIViewController {
        let controller = handler.buildDatePickerAlert(size: size, date: selectedValue) { date in
            self.selectedValue = date
        } handler: { success in
            if success {
                self.completion(self.selectedValue)
            }
        }
        return controller
    }
}
