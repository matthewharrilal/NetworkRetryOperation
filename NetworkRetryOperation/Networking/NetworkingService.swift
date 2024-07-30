//
//  NetworkingService.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import Foundation

protocol NetworkingServiceProtocol: AnyObject {
    
    var retryAmount: Int { get }
    
    func executeRequest(url: URL?, initialRetryCount: Int) async -> Results?
}

class NetworkingServiceImplementation: Operation {
    
    var retryAmount: Int
    
    // Goal of this class it to take a URL and retry x amount of times. X is configurable
    // We want to use dependency inversion for this but how would this work and why
    // Why? - We want to not tightly couple the implementation of NetworkingService to the View Controller
    // How? -
    
    init(retryAmount: Int) {
        self.retryAmount = retryAmount
    }
    
//    override func main() {
//        super.main()
//        
//        Task {
//            await executeRequest(url: URL(string: "https://pokeapi.co/api/v2/pokemon"), with: 3)
//        }
//    }
}

extension NetworkingServiceImplementation: NetworkingServiceProtocol {
    
    func executeRequest(url: URL?, initialRetryCount: Int = 0) async -> Results? {
        var currentCountForRetry = initialRetryCount
        
        guard
            let url = url,
            currentCountForRetry <= retryAmount
        else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode(Results.self, from: data)
            print("Successfully decoded results")
            return results
        }
        catch {

            if currentCountForRetry <= retryAmount {
                currentCountForRetry += 1
                print("Retrying request for the \(currentCountForRetry) time")
                return await executeRequest(url: url, initialRetryCount: currentCountForRetry)
            } else {
                print("Retrying request for the \(currentCountForRetry) time")
                print("Error trying to decode results")
                return nil
            }
        }
    }
}
