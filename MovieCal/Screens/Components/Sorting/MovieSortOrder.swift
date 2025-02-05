//
//  MovieSortOrder.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation

enum MovieSortOrder: String, CaseIterable, Identifiable {
    case peopleCount
    case releaseDate
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .peopleCount: "Number of people"
        case .releaseDate: "Release date"
        }
    }
    
    func orderedAscending(lhs: CreditedMovie, rhs: CreditedMovie) -> Bool {
        switch self {
        case .peopleCount: return lhs.people.count < rhs.people.count
        case .releaseDate: return lhs.movie.releaseDate < rhs.movie.releaseDate
        }
    }
}

extension Array where Element == CreditedMovie {
    func sorted(in order: MovieSortOrder, ascending: Bool) -> Self {
        sorted(by: { order.orderedAscending(lhs: $0, rhs: $1) }, ascending: ascending)
    }
}
