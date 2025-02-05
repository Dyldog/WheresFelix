//
//  View+SortButton.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import SwiftUI

struct MovieSortButon: View {
    
    let viewModel: MovieSortingViewModel
    @State var sortPresented: Bool = false
    let onUpdate: () -> Void
    
    var body: some View {
        Button(systemName: viewModel.sortAscending ? "arrow.up" : "arrow.down") {
            sortPresented = true
        }
        .confirmationDialog(
            "Sort Order",
            isPresented: $sortPresented,
            actions:  {
                sortOrderButtons
            }, 
            message: {
                sortSheetMessage
            })
    }
    
    private var sortSheetMessage: some View {
        Text("Sorting by \(viewModel.sortOrder.title.lowercased()) (\(viewModel.sortAscending ? "ascending" : "descending"))")
    }
    
    @ViewBuilder
    private var sortOrderButtons: some View {
        Button(viewModel.sortAscending ? "Sort descending" : "Sort ascending") {
            viewModel.sortAscending.toggle()
            onUpdate()
        }
        
        ForEach(MovieSortOrder.allCases) { order in
            if viewModel.sortOrder != order {
                Button {
                    viewModel.sortOrder = order
                    onUpdate()
                } label: {
                    HStack {
                        Text("Sort by \(order.title.lowercased())")
                    }
                }
            }
        }
    }
}
