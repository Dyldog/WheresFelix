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
    @State var showFileImporter: Bool = false
    
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
        .navigationTitle("Where's Felix?")
        .toolbar {
            HStack {
                Button {
                    viewModel.searchTapped()
                } label: {
                    Image(systemName: "plus")
                }
                
                Button {
                    viewModel.filterTapped()
                } label: {
                    Image(systemName: "camera.filters")
                }
                
                Button {
                    viewModel.hideMode.toggle()
                } label: {
                    Image(systemName: "eye.slash.fill")
                }
                
                Button {
                    viewModel.sortButtonTapped()
                } label: {
                    Image(systemName: viewModel.sortAscending ? "arrow.down" : "arrow.up")
                }
            }
        }
        .sheet(item: $viewModel.searchViewModel) {
            SearchView(viewModel: $0)
        }
        .if(viewModel.showNotes) {
            $0.fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.folder]) { result in
                showFileImporter = false
                
                switch result {
                case let .success(url): viewModel.didSelectNotesFolder(url)
                case .failure: break
                }
            }
        }.onAppear {
            showFileImporter = true
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
