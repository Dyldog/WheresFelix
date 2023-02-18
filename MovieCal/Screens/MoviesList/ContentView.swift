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
    @StateObject var viewModel: ContentViewModel = .init()
    @State var showSearch: Bool = false
    
    var body: some View {
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
        .toolbar {
            Button {
                showSearch = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView {
                viewModel.didAddPerson($0)
                showSearch = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
