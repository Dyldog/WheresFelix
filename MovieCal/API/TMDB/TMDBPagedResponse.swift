//
//  TMDBPagedResponse.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

struct TMDBPagedResponse<T: Decodable>: Decodable {
    let results: [T]
}
