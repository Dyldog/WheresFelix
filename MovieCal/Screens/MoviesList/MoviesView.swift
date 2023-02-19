//
//  MoviesView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import NukeUI

struct MoviesView: View {
    @ObservedObject var viewModel: ContentViewModel
        
    var body: some View {
        List {
            ForEach(viewModel.movieRows) { movie in
                HStack {
                    LazyImage(url: movie.imageURL)
                        .frame(width: 100, height: 150)
                    VStack {
                        Text(movie.title)
                        Text(movie.credits).font(.subheadline)
                    }
                }
            }
        }
        .toolbar {
            Button("Filter") {
                viewModel.filterTapped()
            }
        }
        .sheet(item: $viewModel.filterViewModel, content: {
            FilterView(viewModel: $0)
        })
    }
}
