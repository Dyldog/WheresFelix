//
//  DetailView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import SwiftUI

struct DetailView: View {
    let viewModel: MovieDetailViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text(viewModel.description)
                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.title)
        }
    }
}
