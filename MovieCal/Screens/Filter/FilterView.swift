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
                hideUnreleased
            }
            
            Section("Genre") {
                genres
            }
        }
    }
    
    private var hideUnreleased: some View {
        HStack {
            Text("Hide unreleased")
            Spacer()
            Toggle("Hide unreleased", isOn: .init(get: {
                viewModel.hideUnreleased
            }, set: {
                viewModel.didSetHideUnreleased($0)
            })).labelsHidden()
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
    
    @ViewBuilder
    private var genres: some View {
        Picker("Genre Mode", selection: .init(get: {
            viewModel.excludeGenres
        }, set: {
            viewModel.didSetExcludeGenres($0)
        })) {
            Text("Include").tag(false)
            Text("Exclude").tag(true)
        }
        
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
