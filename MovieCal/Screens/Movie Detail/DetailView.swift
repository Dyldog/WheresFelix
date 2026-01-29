//
//  DetailView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation
import SwiftUI
import NukeUI

struct DetailView: View {
    @ObservedObject var viewModel: MovieDetailViewModel
    
    let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(viewModel.description)
                }
                
                Section("Actors you've added") {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.knownActors) { person in
                            Button {
                                viewModel.knownPersonTapped(person)
                            } label: {
                                VStack(alignment: .center) {
                                    LazyImage(url: person.imageURL){ state in
                                        state.image?.resizable()
                                    }
                                    .aspectRatio(1.0/1.5, contentMode: .fit)
                                    .cornerRadius(10)
                                    Text(person.name)
                                        .font(.caption).bold()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical)
                }
                
                Section("Other actors") {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.otherActors) { person in
                            Button {
                                viewModel.personTapped(person)
                            } label: {
                                VStack(alignment: .center) {
                                    LazyImage(url: person.imageURL) { state in
                                        state.image?.resizable()
                                    }
                                    .aspectRatio(1.0/1.5, contentMode: .fit)
                                    .cornerRadius(10)
                                    Text(person.name)
                                        .font(.caption).bold()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .toolbar {
                Button("Hide") {
                    viewModel.hideTapped()
                }
            }
            .navigationTitle(viewModel.title)
        }
        .sheet(item: $viewModel.personDetailViewModel) { model in
            NavigationView {
                PersonDetailView(viewModel: model)
            }
        }
    }
}
