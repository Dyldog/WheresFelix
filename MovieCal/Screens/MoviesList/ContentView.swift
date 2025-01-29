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
            navigationBarButtons
        }
        .sheet(item: $viewModel.searchViewModel) {
            SearchView(viewModel: $0)
        }
        .confirmationDialog("Sort Order", isPresented: $viewModel.showSortOrderSheet, actions:  {
            sortOrderButtons
        }, message: { sortSheetMessage })
        
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
    
    private var navigationBarButtons: some View {
        HStack {
            Button(systemName: "plus") { viewModel.searchTapped() }
            Button(systemName: "camera.filters") { viewModel.filterTapped() }
            Button(systemName: "eye.slash.fill") { viewModel.hideMode.toggle() }
            Button(systemName: viewModel.sortAscending ? "arrow.up" : "arrow.down") { viewModel.sortButtonTapped() }
        }
    }
    
    private var sortSheetMessage: some View {
        Text("Sorting by \(viewModel.sortOrder.title.lowercased()) (\(viewModel.sortAscending ? "ascending" : "descending"))")
    }
    
    @ViewBuilder
    private var sortOrderButtons: some View {
        Button(viewModel.sortAscending ? "Sort descending" : "Sort ascending") {
            viewModel.didSelectSortOrderToggle()
        }
        
        ForEach(ContentViewModel.SortOrder.allCases) { order in
            if viewModel.sortOrder != order {
                Button {
                    viewModel.didSelectSortOrder(order)
                } label: {
                    HStack {
                        Text("Sort by \(order.title.lowercased())")
                    }
                }
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

extension Button {
    init(systemName: String, action: @escaping () -> Void) where Label == SwiftUI.Image {
        self.init(action: action, label: {
            Image(systemName: systemName)
        })
    }
}
