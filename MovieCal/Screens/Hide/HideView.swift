//
//  HideView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 20/10/2023.
//

import SwiftUI
import NukeUI
import DylKit

struct HideView: View {
    @ObservedObject var viewModel: HideViewModel
    
    var body: some View {
        VStack {
            if let movie = viewModel.movie {
                HideMovieView(movie: movie.movie, people: viewModel.people, onSelect: {
                    viewModel.peopleSelected($0, hide: $1)
                })
                .id(movie.id)
            } else {
                ProgressView().progressViewStyle(.circular)
            }
        }
    }
}
