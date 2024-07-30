//
//  NetworkingService.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import Foundation

protocol NetworkRetryProtocol: AnyObject {
    var retryAmount: Int { get }
    var queuedURLs: [URL?] { get }
    func executeRequest(url: URL?, initialRetryCount: Int) async -> Results?
}

class NetworkRetryImplementation: Operation {
    
    var retryAmount: Int
    
    var queuedURLs: [URL?]
    
    // Goal of this class it to take a URL and retry x amount of times. X is configurable
    // We want to use dependency inversion for this but how would this work and why
    // Why? - We want to not tightly couple the implementation of NetworkingService to the View Controller
    // How? -
    
    
    // Now what?
    // 1. We have the ability to retry logic, now we queue subsequent requests
    // 2. How do we bridge the two?
    // 3. Upon success, my initial thought is to have this class have acccess to the queue of URLs and then execute them in parallel upon success
    init(retryAmount: Int, queuedURLs: [URL?]) {
        self.retryAmount = retryAmount
        self.queuedURLs = queuedURLs
    }
}

extension NetworkRetryImplementation: NetworkRetryProtocol {
    
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
            await executeQueuedRequests(urls: queuedURLs)
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
