//
//  Ferrari.swift
//  NetworkRetryOperation
//
//  Created by Space Wizard on 8/1/24.
//

import Foundation
import UIKit

protocol DrivingProtocol: AnyObject {
    func drive()
    func park()
}

class Ferrari: DrivingProtocol {
    
    func drive() {
        print("Ferrari Driving")
    }
    
    func park() {
        print("Ferrari Parking")
    }
}

class Toyota: DrivingProtocol {
    func drive() {
        print("Toyota Driving")
    }
    
    func park() {
        print("Toyota Parking")
    }
}
