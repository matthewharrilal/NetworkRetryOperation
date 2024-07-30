//
//  NetworkingService.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import Foundation

protocol NetworkingServiceProtocol: AnyObject {
    
    func executeRequest(url: URL?, with currentRetryCount: Int) async -> Results?
}

class NetworkingService: Operation {
    
    let retryAmount: Int
    // Goal of this class it to take a URL and retry x amount of times. X is configurable
    // We want to use dependency inversion for this but how would this work and why
    // Why? - We want to not tightly couple the implementation of NetworkingService to the View Controller
    // How? -
    
    init(retryAmount: Int) {
        self.retryAmount = retryAmount
        super.init()
    }
}

extension NetworkingService: NetworkingServiceProtocol {
    
    func executeRequest(url: URL?, with currentRetryCount: Int = 0) async -> Results? {
        guard let url = url else { return nil }
        
        var currentCountForRetry = currentRetryCount
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode(Results.self, from: data)
            return results
        }
        catch {

            if currentCountForRetry <= retryAmount {
                currentCountForRetry += 1
                print("Retrying request for the \(currentCountForRetry) time")
                return await executeRequest(url: url, with: currentCountForRetry)
            } else {
                print("Error trying to decode results")
                return nil
            }
        }
    }
}
