//
//  Person.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct Person: Codable, FetchableRecord, PersistableRecord, TableRecord {
    let id: Int
    let name: String
    let imageURL: URL?
}
