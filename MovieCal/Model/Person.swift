//
//  Person.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct Person: Codable, FetchableRecord, PersistableRecord, TableRecord, Identifiable, Hashable, Equatable {
    let id: Int
    let name: String
    let imageURL: URL?
    
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
}
