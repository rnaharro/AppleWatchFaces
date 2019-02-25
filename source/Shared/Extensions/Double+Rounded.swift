//
//  Double+Rounded.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 2/24/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
