//
//  ViewController.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import UIKit

class RetryViewController: UIViewController {
    let networkingService: NetworkingServiceProtocol
    
    init(networkingService: NetworkingServiceProtocol) {
        self.networkingService = networkingService
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
            try await networkingService.executeRequest(url: URL(string: "https://pokeapi.co/api/v2/pokeon"), initialRetryCount: 0)
        }
    }
}
