//
//  AddedPeopleViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation
import DylKit
import SwiftUI

class AddedPeopleViewModel: NSObject, ObservableObject {
    private let database: Database
    
    @Published private var unfilteredPeopleRows: [PersonCellModel] = []
    @Published var showLoading: Bool = false
    @Published var searchText: String = ""
    @Published var detailViewModel: PersonDetailViewModel?
    
    var peopleRows: [PersonCellModel] {
        guard !searchText.isEmpty else { return unfilteredPeopleRows }
        
        func sanitise(_ text: String) -> String {
            text
                .components(separatedBy: .whitespacesAndNewlines).joined()
                .lowercased()
        }
        
        let sanitisedQuery = sanitise(searchText)
        
        return unfilteredPeopleRows.filter {
            sanitise($0.title).contains(sanitisedQuery)
        }
    }
    
    init(database: Database) {
        self.database = database
        super.init()
        reload()
    }
    
    private func reload() {
        Task { @MainActor in
            showLoading = true
            unfilteredPeopleRows = await database.allPeople().map { person in
                .init(
                    id: person.id,
                    imageURL: person.imageURL ?? Image.placeholderURL,
                    title: person.name
                )
            }
            showLoading = false
        }
    }
    
    func didSelectPerson(_ person: PersonCellModel) {
        detailViewModel = .init(database: database, person: person)
    }
    
    func deletePerson(_ person: PersonCellModel) {
        Task { @MainActor in
            showLoading = true
            let people = await database.allPeople()
            guard let person = people.first(where: { $0.id == person.id }) else { return }
            await database.deletePerson(person)
            reload()
            showLoading = false
        }
    }
}
