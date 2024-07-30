//
//  ViewController.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import UIKit

class RetryViewController: UIViewController {
    let networkRetryService: NetworkRetryProtocol
    
    init(networkRetryService: NetworkRetryProtocol) {
        self.networkRetryService = networkRetryService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {
            // Mispelled URL on purpose to see if retry logic was working
            try await networkRetryService.executeRequest(url: URL(string: "https://pokeapi.co/api/v2/poemon"), initialRetryCount: 0)
        }
    }
}
