//
//  SearchView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import SwiftUI
import NukeUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            searchField
            list
        }
    }
    
    private var searchField: some View {
        TextField("Search...", text: $viewModel.searchText)
            .padding()
    }
    
    private var list: some View {
        List {
            ForEach(viewModel.rows) { model in
                row(for: model)
            }
        }
    }
    
    private func row(for model: SearchCellModel) -> some View {
        Button {
            model.onSelect()
        } label: {
            HStack {
                LazyImage(url: model.imageURL)
                    .frame(width: 100, height: 150)
                    .cornerRadius(10)
                Text(model.text)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

