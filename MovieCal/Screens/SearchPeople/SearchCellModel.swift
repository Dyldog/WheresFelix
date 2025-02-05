//
//  SearchCellModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation

struct SearchCellModel: Identifiable {
    var id: String
    let imageURL: URL
    let text: String
    let onSelect: Block
}
