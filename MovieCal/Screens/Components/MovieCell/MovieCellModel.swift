//
//  MovieCellModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation

struct MovieCellModel: Identifiable {
    let id: Int
    let imageURL: URL
    let title: String
    let credits: String
    let numCredits: Int
    let toBeHidden: Bool
}
