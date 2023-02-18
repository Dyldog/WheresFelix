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
            Section("Genre") {
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
    }
}
