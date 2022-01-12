//
//  AppStateService.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 13.07.21.
//

import UIKit


class AppStateService {
    
    enum State {
        case background
        case foreground
        case active
        case inactive
    }
    
    var stateListeners: [String :(State)->()] = [:]
    
    init() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(willForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func didEnterBackground() {
        stateListeners.values.forEach { listener in
            listener(.background)
        }
    }
    
    @objc func willForeground() {
        stateListeners.values.forEach { listener in
            listener(.foreground)
        }
    }
    
}
