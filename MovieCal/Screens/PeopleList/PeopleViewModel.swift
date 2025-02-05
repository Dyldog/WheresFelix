//
//  PeopleViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation

struct PeopleViewModel {
    let database: Database
    var notesViewModel: PeopleNotesViewModel { .init() }
    var addedViewModel: AddedPeopleViewModel { .init(database: database) }
}
