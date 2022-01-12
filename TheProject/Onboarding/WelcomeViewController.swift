//
//  WelcomeViewController.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 15.03.21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var termsLabel: LinkableTextView!
    
    weak var coordinator: OnboardingCoordinator?
    
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
    }
    
    
    @IBAction func proceedAction(_ sender: Any) {
        coordinator?.welcomeComplete()
    }
}
