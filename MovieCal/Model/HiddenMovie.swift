//
//  HiddenMovie.swift
//  MovieCal
//
//  Created by Dylan Elliott on 20/10/2023.
//

import Foundation
import GRDB

struct HiddenMovie: Codable, FetchableRecord, PersistableRecord {
    let movieId: Int
}
