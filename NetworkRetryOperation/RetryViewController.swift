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
        
        let urls: [URL?] = [
            URL(string: "https://pokeapi.co/api/v2/pokemon/2/"),
            URL(string: "https://pokeapi.co/api/v2/pokemon/3/"),
            URL(string: "https://pokeapi.co/api/v2/pokemon/4/")
        ]
        
        Task {
            // Mispelled URL on purpose to see if retry logic was working
            let results = try await networkRetryService.executeRequest(url: URL(string: "https://pokeapi.co/api/v2/pokmon"), initialRetryCount: 0)
            
            if let results = results {
                try await networkRetryService.executeQueuedRequests(urls: urls)
            }
            
        }
    }
}
