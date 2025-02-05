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
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.movieRows) { movie in
                        Button {
                            viewModel.movieTapped(movie)
                        } label: {
                            VStack {
                                ZStack {
                                    MovieCell(movie: movie)
                                    
                                    if movie.toBeHidden {
                                        Image(systemName: "eye.slash.fill")
                                            .foregroundColor(.red)
                                            .imageScale(.large)
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
            
            if viewModel.hideMode {
                Button(action: {
                    viewModel.hideMoviesTapped()
                }, label: {
                    Text("Hide Movies").padding(.horizontal).frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .sheet(item: $viewModel.filterViewModel, content: {
            FilterView(viewModel: $0)
        })
        .sheet(item: $viewModel.detailViewModel) {
            DetailView(viewModel: $0)
        }
        .sheet(item: $viewModel.hideViewModel, onDismiss: {
            viewModel.onAppear()
        }) {
            HideView(viewModel: $0)
        }
    }
}
