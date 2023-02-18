//
//  Thread+Closures.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation

func onBG(_ work: @escaping () -> Void) {
    DispatchQueue.global().async {
        work()
    }
}

func onMain(_ work: @escaping () -> Void) {
    DispatchQueue.main.async {
        work()
    }
}
