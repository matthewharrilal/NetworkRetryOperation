//
//  NetworkingService.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import Foundation

protocol NetworkRetryProtocol: AnyObject {
    var retryAmount: Int { get }
    var token: String? { get }
    func executeRequest(url: URL?) async -> Results?
    func executeQueuedRequests(urls: [URL?]) async -> AsyncStream<Pokemon?>
}

class NetworkRetryImplementation: Operation {
    
    var retryAmount: Int
    
    var token: String?
        
    // Goal of this class it to take a URL and retry x amount of times. X is configurable
    // We want to use dependency inversion for this but how would this work and why
    // Why? - We want to not tightly couple the implementation of NetworkingService to the View Controller
    // How? -
    
    
    // Now what?
    // 1. We have the ability to retry logic, now we queue subsequent requests
    // 2. How do we bridge the two?
    // 3. Upon success, my initial thought is to have this class have acccess to the queue of URLs and then execute them in parallel upon success
    init(retryAmount: Int) {
        self.retryAmount = retryAmount
    }
}

extension NetworkRetryImplementation: NetworkRetryProtocol {
    
    func executeRequest(url: URL?) async -> Results? {
        var currentCountForRetry = 0
        
        guard
            let url = url,
            currentCountForRetry <= retryAmount
        else { return nil }
        
        while currentCountForRetry <= retryAmount {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let results = try JSONDecoder().decode(Results.self, from: data)
                print("Successfully decoded results")
                self.token = "Hello World"
                return results
            }
            catch {
                currentCountForRetry += 1
                print("Retrying request for the \(currentCountForRetry) time")
            }
        }
        
        return nil
    }
    
    func executeQueuedRequests(urls: [URL?]) async -> AsyncStream<Pokemon?> {
        AsyncStream<Pokemon?> { continuation in
            Task {
                await withTaskGroup(of: Pokemon?.self) { taskGroup in
                    for url in urls {
                        taskGroup.addTask {
                            do {
                                guard let url = url else {
                                    continuation.finish()
                                    return nil
                                }

                                let (data, _) = try await URLSession.shared.data(from: url)
                                let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                                print("Current pokemon: \(pokemon)")
                                return pokemon
                            }
                            catch {
                                print("Error trying to decode pokemon")
                                return nil
                            }
                        }
                    }
                    
                    for await pokemon in taskGroup {
                        continuation.yield(pokemon)
                    }
                    
                    continuation.finish()
                }
            }
        }
    }
}
