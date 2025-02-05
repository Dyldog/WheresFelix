//
//  ContentView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import SwiftUI
import DylKit
import Nuke
import NukeUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            TabView {
                MoviesView(viewModel: viewModel)
                    .tabItem {
                        Label("Movies", systemImage: "film")
                    }
                
                PeopleView(viewModel: viewModel.peopleViewModel)
                    .tabItem {
                        Label("People", systemImage: "person")
                    }
            }
            
            if viewModel.showLoading {
                loadingIndicator
            }
        }
        .navigationTitle("Where's Felix?")
        .toolbar {
            navigationBarButtons
        }
        .sheet(item: $viewModel.searchViewModel) {
            SearchView(viewModel: $0)
        }
        .notesPresenter(with: viewModel)
    }
    
    private var navigationBarButtons: some View {
        HStack {
            Button(systemName: "plus") { viewModel.searchTapped() }
            Button(systemName: "camera.filters") { viewModel.filterTapped() }
            Button(systemName: "eye.slash.fill") { viewModel.hideMode.toggle() }
            MovieSortButon(viewModel: viewModel, onUpdate: {
                viewModel.reloadCells()
            })
        }
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

