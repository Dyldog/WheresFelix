//
//  Genre.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import GRDB

struct Genre: Codable, Hashable, Identifiable, FetchableRecord, PersistableRecord {
    let id: Int
    let name: String
}
