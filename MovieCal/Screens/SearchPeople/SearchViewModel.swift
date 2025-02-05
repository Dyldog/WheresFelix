//
//  SearchViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import SwiftUI

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
