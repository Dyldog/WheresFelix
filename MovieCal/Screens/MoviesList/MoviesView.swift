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
    
    let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.movieRows) { movie in
                    Button {
                        viewModel.movieTapped(movie)
                    } label: {
                        VStack {
                            ZStack {
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
                            Text(movie.title)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .sheet(item: $viewModel.filterViewModel, content: {
            FilterView(viewModel: $0)
        })
        .sheet(item: $viewModel.detailViewModel) {
            DetailView(viewModel: $0)
        }
    }
}
