//
//  OnboardingProfileViewController.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 18.07.21.
//

import UIKit

extension OnboardingProfileViewController {
    enum HealthKitStatus {
        case granted
        case limited
    }
}

class OnboardingProfileViewController: UIViewController {
    
    weak var coordinator: OnboardingCoordinator?
    
    var status: HealthKitStatus = .limited {
        didSet {
            if isViewLoaded {
                setup(status: status)
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var termsLabel: LinkableTextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var healthKitView: UIView!
    @IBOutlet weak var healthKitViewHeightConstraint: NSLayoutConstraint!
    
    var tableViewHandler: BodyProfileTableViewHandler?
    
    var weightPicker: WeightPickerViewHandler?
    var heightPicker: HeightPickerViewHandler?
    var sexPicker: SexPickerViewHandler?
    var dobPicker: DatePickerViewHandler?
    
    lazy var personalData = coordinator?.properties.userPersonalData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string: "By tapping Continue, you are confirming that you have reviewed\nand accepted out Privacy Policy and Terms.", attributes: [
            .font: UIFont.systemFont(ofSize: 12.0).rounded,
            .foregroundColor: UIColor(white: 161.0 / 255.0, alpha: 1.0),
            .kern: -0.29
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 103.0 / 255.0, green: 79.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0), range: NSRange(location: 80, length: 14))
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 102.0 / 255.0, green: 78.0 / 255.0, blue: 234.0 / 255.0, alpha: 1.0), range: NSRange(location: 99, length: 5))
        
        termsLabel.attributedText = attributedString
        termsLabel.textAlignment = .center
        termsLabel.setLink("Privacy Policy") { [weak self] in
            self?.coordinator?.openTermsController(content: .policy)
        }
        termsLabel.setLink("Terms") { [weak self] in
            self?.coordinator?.openTermsController(content: .terms)
        }
        
        guard let personalData = personalData else {
            assertionFailure()
            return
        }
        
        tableViewHandler = BodyProfileTableViewHandler(tableView: tableView, userData: personalData)
        tableViewHandler?.delegate = self
        
        weightPicker = WeightPickerViewHandler(selectedValue: personalData.bodyMass, completion: { [weak self] weight in
            self?.personalData?.bodyMass = weight
            self?.updateUserPersonalData()
        })
        
        sexPicker = SexPickerViewHandler(selectedValue: personalData.sex, completion: { [weak self] sex in
            self?.personalData?.sex = sex
            self?.updateUserPersonalData()
        })
        
        heightPicker = HeightPickerViewHandler(selectedValue: personalData.height, completion: { [weak self] height in
            self?.personalData?.height = height
            self?.updateUserPersonalData()
        })
        
        dobPicker = DatePickerViewHandler(selectedValue: personalData.dateOfBirth, completion: { [weak self] date in
            self?.personalData?.dateOfBirth = date
            self?.updateUserPersonalData()
        })
        
        setup(status: status)
    }
    
    func setup(status: HealthKitStatus) {
        switch status {
        case .granted:
            healthKitView.isHidden = true
            healthKitViewHeightConstraint.constant = 0
            titleLabel.text = "Check your data\nfor correct calories\ncalculations"
        case .limited:
            healthKitView.isHidden = false
            healthKitViewHeightConstraint.constant = 140
            titleLabel.text = "Setup for correct\ncalories calculations"
        }
    }
    
    func updateUserPersonalData() {
        guard let personalData = personalData else {
            assertionFailure()
            return
        }
        
        coordinator?.properties.userPersonalData = personalData
        coordinator?.properties.synchronize()
        tableViewHandler?.userData = personalData
        tableViewHandler?.reload()
    }
    
    
    func presentSexPicker() {
        let size = CGSize(width: view.bounds.width/1.2, height: 200)
        guard let alert = sexPicker?.buildPickerAlert(size: size) else {
            assertionFailure()
            return
        }
        present(alert, animated: true)
    }
    
    func presentWeightPicker() {
        let size = CGSize(width: view.bounds.width/1.2, height: 200)
        guard let alert = weightPicker?.buildPickerAlert(size: size) else {
            assertionFailure()
            return
        }
        present(alert, animated: true)
    }
    
    func presentHeightPicker() {
        let size = CGSize(width: view.bounds.width/1.2, height: 200)
        guard let alert = heightPicker?.buildPickerAlert(size: size) else {
            assertionFailure()
            return
        }
        present(alert, animated: true)
    }
    
    func presentDobPicker() {
        let size = CGSize(width: view.bounds.width/1.2, height: 200)
        guard let alert = dobPicker?.buildPickerAlert(size: size) else {
            assertionFailure()
            return
        }
        present(alert, animated: true)
    }
    
    
    @IBAction func proceedAction(_ sender: Any) {
        (sender as? UIView)?.isUserInteractionEnabled = false
        coordinator?.profileDone()
    }
    
}

extension OnboardingProfileViewController: BodyProfileTableViewHandlerDelegate {
    func didSelectSex() {
        presentSexPicker()
    }
    
    func didSelectBirthday() {
        presentDobPicker()
    }
    
    func didSelectWeight() {
        presentWeightPicker()
    }
    
    func didSelectHeight() {
        presentHeightPicker()
    }
}
