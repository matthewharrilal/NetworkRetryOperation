//
//  NetworkQueueOperation.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import Foundation
import UIKit

protocol NetworkQueueProtocol: AnyObject {
    func executeQueuedRequests(urls: [URL?]) async -> AsyncStream<Pokemon?>
}

class NetworkQueueOperation: Operation {
    var token: String?
    
    init(token: String?) {
        self.token = token
    }
}

extension NetworkQueueOperation: NetworkQueueProtocol {
    
    func executeQueuedRequests(urls: [URL?]) async -> AsyncStream<Pokemon?> {
        print("Got the token! \(token)")
        return AsyncStream<Pokemon?> { continuation in
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
