//
//  Blocks.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

typealias Block = () -> Void
typealias BlockIn<T> = (T) -> Void
typealias BlockOut<T> = () -> T
typealias BlockInOut<S, T> = (S) -> T
