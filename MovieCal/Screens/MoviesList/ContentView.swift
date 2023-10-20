//
//  ContentView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import SwiftUI
import Nuke
import NukeUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State var showSearch: Bool = false
    
    var body: some View {
        ZStack {
            TabView {
                MoviesView(viewModel: viewModel)
                    .tabItem {
                        Label("Movies", systemImage: "film")
                    }
                PeopleView(viewModel: viewModel)
                    .tabItem {
                        Label("People", systemImage: "person")
                    }
            }
            
            if viewModel.showLoading {
                loadingIndicator
            }
        }
        .toolbar {
            HStack {
                Button {
                    showSearch = true
                } label: {
                    Image(systemName: "plus")
                }
                
                Button {
                    viewModel.filterTapped()
                } label: {
                    Image(systemName: "camera.filters")
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView {
                viewModel.didAddPerson($0)
                showSearch = false
            }
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
