//
//  SearchView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import SwiftUI
import NukeUI

struct SearchCellModel: Identifiable {
    var id: String
    let imageURL: URL
    let text: String
    let onSelect: Block
}

class SearchViewModel: ObservableObject, Identifiable {
    
    let id: UUID = .init()
    private let movies: MovieClient = .shared
    private var results: [Person] = []
    
    @Published var rows: [SearchCellModel] = []
    let knownPeople: [Person]
    let onSelect: BlockIn<Person>
    
    var searchText: String = "" { didSet { search() } }
    private var searchRequest: URLSessionDataTask?
    
    init(known: [Person], onSelect: @escaping BlockIn<Person>) {
        self.knownPeople = known
        self.onSelect = onSelect
    }

    private func search() {
        searchRequest?.cancel()
        
        searchRequest = movies.searchPeople(for: searchText, completion: { result in
            onMain {
                if case let .success(people) = result {
                    self.results = people
                    self.rows = people.filter { !self.knownPeople.contains($0) }.map { person in
                            .init(
                                id: "\(person.id)",
                                imageURL: person.imageURL ?? Image.placeholderURL,
                                text: person.name,
                                onSelect: { self.onSelect(person) }
                            )
                    }
                }
            }
        })
    }
}

struct SearchView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TextField("Search...", text: $viewModel.searchText)
                .padding()
            List {
                ForEach(viewModel.rows) { row in
                    Button {
                        row.onSelect()
                    } label: {
                        HStack {
                            LazyImage(url: row.imageURL)
                                .frame(width: 100, height: 150)
                                .cornerRadius(10)
                            Text(row.text)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

