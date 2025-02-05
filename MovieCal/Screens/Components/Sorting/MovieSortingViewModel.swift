//
//  MovieSortingViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import SwiftUI

protocol MovieSortingViewModel: AnyObject {
    var sortOrder: MovieSortOrder { get set }
    var sortAscending: Bool { get set }
}
