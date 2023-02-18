//
//  APICompletion.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

typealias APICompletion<T> = BlockIn<Result<T, APIError>>
