//
//  TermsViewController.swift
//  TheProject
//
//  Created by Dzmitry Mazyrchuk on 26.07.21.
//

import UIKit
import WebKit

extension TermsViewController {
    
    private struct URLS {
        static let terms = "https://pedometer.tilda.ws/terms_of_use"
        static let policy = "https://pedometer.tilda.ws/privacy_policy"
    }
    
    enum Content {
        case terms
        case policy
        
        var url: URL {
            switch self {
            case .terms:
                return URL(string: URLS.terms)!
            case .policy:
                return URL(string: URLS.policy)!
            }
        }
    }
}

class TermsViewController: UIViewController {
    
    weak var coordinator: OnboardingCoordinator?
    
    var content: Content = .policy
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = URLRequest(url: content.url)
        webView.load(request)
    }
    
    @IBAction func backAction() {
        coordinator?.termsControllerDone()
    }
}
