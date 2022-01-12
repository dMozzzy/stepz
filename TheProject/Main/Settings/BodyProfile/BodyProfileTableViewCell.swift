//
//  BodyProfileTableViewCell.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 2.06.21.
//

import UIKit

class BodyProfileTableViewCell: UITableViewCell {
    
    enum Style: CaseIterable {
        case sex
        case weight
        case height
        case birthday
    }
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    
    var style: Style = .sex {
        didSet { setup(style: style) }
    }
    
    var userData: UserPersonalData?
    
    var selectionHandler: (BodyProfileTableViewCell)->Void = {_ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        background.layer.cornerRadius = 8.0
    }
    
    func setup(style: Style) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        switch style {
        case .sex:
            title.text = "Sex"
            value.text = userData?.sex.description
        case .weight:
            title.text = "Weight"
            value.text = String(format: "%.1f", userData?.bodyMass ?? 0)
        case .height:
            title.text = "Height"
            value.text = String(format: "%.1f", userData?.height ?? 0)
        case .birthday:
            title.text = "Date of birth"
            value.text = formatter.string(from: userData?.dateOfBirth ?? Date())
        }
    }
    
    @IBAction func touchDownAction(_ sender: Any) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 1.08, y: 1.1)
        } completion: { _ in }
    }
    @IBAction func touchUpAction(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut]) {
            self.transform = .identity
        } completion: { _ in }
        selectionHandler(self)
    }
    @IBAction func touchUpoutside(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0.1, options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut]) {
            self.transform = .identity
        } completion: { _ in }
    }
    
}

