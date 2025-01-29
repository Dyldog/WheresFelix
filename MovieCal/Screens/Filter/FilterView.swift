//
//  FilterView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: FilterViewModel
    
    var body: some View {
        List {
            Section {
                minimumActors
            }
            
            Section("Genre") {
                genres
            }
        }
    }
    
    private var minimumActors: some View {
        HStack {
            Text("Minimum Actors").frame(maxWidth: .infinity, alignment: .leading)
            Stepper(viewModel.minimumActorsTitle) {
                viewModel.didIncreaseMinimumActors()
            } onDecrement: {
                viewModel.didDecreaseMinimumActors()
            }
            .font(.body.bold())
            .fixedSize()

        }
    }
    
    private var genres: some View {
        ForEach(viewModel.genres) { genre in
            Button {
                viewModel.didSelect(genre)
            } label: {
                HStack {
                    Text(genre.name)
                    Spacer()
                    if viewModel.isSelected(genre) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
