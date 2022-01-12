//
//  BodyProfileTableViewHandler.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 2.06.21.
//

import UIKit

protocol BodyProfileTableViewHandlerDelegate: AnyObject{
    func didSelectSex()
    func didSelectBirthday()
    func didSelectWeight()
    func didSelectHeight()
}

class BodyProfileTableViewHandler: NSObject {
    
    let tableView: UITableView
    
    var userData: UserPersonalData?
    
    weak var delegate: BodyProfileTableViewHandlerDelegate?
    
    init(tableView: UITableView,userData: UserPersonalData?) {
        self.tableView = tableView
        self.userData = userData
        super.init()
//        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func handler(cell: BodyProfileTableViewCell) {
        switch cell.style {
        case .sex:
            delegate?.didSelectSex()
        case .weight:
            delegate?.didSelectWeight()
        case .height:
            delegate?.didSelectHeight()
        case .birthday:
            delegate?.didSelectBirthday()
        }
    }
    
}

extension BodyProfileTableViewHandler: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BodyProfileTableViewCell", for: indexPath) as! BodyProfileTableViewCell
        cell.selectionHandler = handler(cell:)
        cell.userData = userData
        switch indexPath.row {
        case 0:
            cell.style = .sex
        case 1:
            cell.style = .birthday
        case 2:
            cell.style = .weight
        case 3:
            cell.style = .height
        default:
            fatalError()
        }
        return cell
    }
}

