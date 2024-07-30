//
//  Pokemon.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 7/30/24.
//

import Foundation
import UIKit

struct Results: Decodable {
    let results: [Result]
}

struct Result: Decodable {
    let name: String?
    let url: String
}

struct Pokemon: Decodable {
    let name: String
}
