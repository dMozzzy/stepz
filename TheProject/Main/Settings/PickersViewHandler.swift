//
//  SettingsPickerViewHandler.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 24.05.21.
//

import UIKit

protocol PickerViewHandlerDelegate: AnyObject {
    func numberOfComponents() -> Int
    func numberOfRowsInComponent(_ component: Int) -> Int
    func titleForRow(_ row: Int, component: Int) -> String?
    
    func didSelectRow(_ row: Int, component: Int)
}

class PickerViewHandler: NSObject {
    weak var delegate: PickerViewHandlerDelegate?
    
    var dateSelectionHandler: ((Date) -> Void)?
    
    func buildPickerAlert(size: CGSize, selection: [(row: Int, component: Int)], completion: @escaping (Bool) -> Void) -> UIViewController {
        
        let width = size.width
        let height = size.height
        
        let controller = UIViewController()
        controller.preferredContentSize.height = height
        
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: -100, width: width, height: height))
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        
        for selected in selection {
            pickerView.selectRow(selected.row, inComponent: selected.component, animated: false)
        }
        controller.view.addSubview(pickerView)
        
        NSLayoutConstraint.activate(
            [pickerView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
             pickerView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor)]
        )
        
        let pickerAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        pickerAlert.setValue(controller, forKey: "contentViewController")
        
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            pickerAlert.dismiss(animated: true, completion: nil)
            completion(true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            pickerAlert.dismiss(animated: true, completion: nil)
            completion(false)
        })
        pickerAlert.addAction(doneAction)
        pickerAlert.addAction(cancelAction)
        
        return pickerAlert
    }
    
    func buildDatePickerAlert(size: CGSize, date: Date, valueChanged: @escaping (Date) -> Void, handler: @escaping (Bool) -> Void) -> UIViewController {
        
        dateSelectionHandler = valueChanged
        
        let width = size.width
        let height = size.height
        
        let controller = UIViewController()
        controller.preferredContentSize.height = height
        
        let picker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: width, height: height))
        picker.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        let isoDate = "1900-01-01T00:00:00+0000"

        let dateFormatter = ISO8601DateFormatter()
        let minDate = dateFormatter.date(from:isoDate)!
        
        picker.minimumDate = minDate
        picker.date = date
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        controller.view.addSubview(picker)
        
        NSLayoutConstraint.activate(
            [picker.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
             picker.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor)]
        )
        
        let pickerAlert = UIAlertController(title: "Steps", message: nil, preferredStyle: .actionSheet)
        pickerAlert.setValue(controller, forKey: "contentViewController")
        
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            pickerAlert.dismiss(animated: true, completion: nil)
            handler(true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            pickerAlert.dismiss(animated: true, completion: nil)
            handler(false)
        })
        pickerAlert.addAction(doneAction)
        pickerAlert.addAction(cancelAction)
        
        return pickerAlert
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        dateSelectionHandler?(sender.date)
    }
    
}

extension PickerViewHandler: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectRow(row, component: component)
    }
}

extension PickerViewHandler: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        delegate?.numberOfComponents() ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        delegate?.numberOfRowsInComponent(component) ?? 0
    }
     
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        delegate?.titleForRow(row, component: component)
    }
}

class StepsPickerViewHandler {
    let range = 1...60
    let step = 500
    let offset = 1
    
    let completion: (Int) -> Void
    var selectedValue: Int
    
    let handler = PickerViewHandler()
    
    init(selectedValue: Int?, completion: @escaping (Int) -> Void) {
        self.selectedValue = selectedValue ?? 0
        self.completion = completion
        handler.delegate = self
    }
    
    func buildPickerAlert(size: CGSize) -> UIViewController {
        
        let selectedRow = selectedValue / step - offset
        let controller = handler.buildPickerAlert(size: size, selection: [(row: selectedRow, component: 0)]) { success in
            if success {
                self.completion(self.selectedValue)
            }
        }
        
        return controller
    }
}

extension StepsPickerViewHandler: PickerViewHandlerDelegate {
    func numberOfComponents() -> Int {
        1
    }
    
    func numberOfRowsInComponent(_ component: Int) -> Int {
        range.count
    }
    
    func titleForRow(_ row: Int, component: Int) -> String? {
        let value = range[range.index(range.startIndex, offsetBy: row)] * step
        return "\(value)"
    }
    
    func didSelectRow(_ row: Int, component: Int) {
        let value = range[range.index(range.startIndex, offsetBy: row)] * step
        selectedValue = value
    }
}

class MetricsPickerViewHandler {
    
    let completion: (MetricSystem) -> Void
    var selectedValue: MetricSystem
    
    let handler = PickerViewHandler()
    
    init(selectedValue: MetricSystem, completion: @escaping (MetricSystem) -> Void) {
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

extension MetricsPickerViewHandler: PickerViewHandlerDelegate {
    func numberOfComponents() -> Int {
        1
    }
    
    func numberOfRowsInComponent(_ component: Int) -> Int {
        MetricSystem.allCases.count
    }
    
    func titleForRow(_ row: Int, component: Int) -> String? {
        let value = MetricSystem.allCases[row]
        return "\(value.title)"
    }
    
    func didSelectRow(_ row: Int, component: Int) {
        let value = MetricSystem.allCases[row]
        selectedValue = value
    }
}
