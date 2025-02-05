//
//  PersonDetailView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import SwiftUI

struct PersonDetailView: View {
    @StateObject var viewModel: PersonDetailViewModel
    let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)

    var body: some View {
        content
    }
    
    private var content: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.movieRows) { movie in
                        cell(for: movie)
                    }
                }
                .padding()
            }
            
            if viewModel.showLoading {
                loadingIndicator
            }
        }
        .navigationTitle(viewModel.title)
        .notesPresenter(with: viewModel)
        .sheet(item: $viewModel.detailViewModel) {
            DetailView(viewModel: $0)
        }
    }
    
    private func cell(for movie: MovieCellModel) -> some View {
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
    
    private var loadingIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: 80)
                .aspectRatio(1, contentMode: .fit)
                .opacity(0.9)
            
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}
