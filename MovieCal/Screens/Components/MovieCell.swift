//
//  MovieCell.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import SwiftUI
import NukeUI

struct MovieCell: View {
    let movie: MovieCellModel
    
    var body: some View {
        LazyImage(url: movie.imageURL)
            .aspectRatio(1.0/1.5, contentMode: .fit)
            .cornerRadius(10)
            .overlay(alignment: .bottomTrailing) {
                Text("\(movie.numCredits)")
                    .padding(.horizontal, 6)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .font(.body.bold())
                    .cornerRadius(10)
                    .padding(4)
            }
    }
}
