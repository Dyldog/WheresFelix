//
//  NotesViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation

class PeopleNotesViewModel: NotesViewModel, ObservableObject {
    let notes: NotesClient = .shared
    @Published var showLoading: Bool = false
    
    var noterows: [NotePersonModel] = []
    
    init() {
        showLoading = true
        loadNotes()
    }
    
    func onLoadNotes() {
        Task {
            let movieNotes = notes.movieNotes()
            
            self.noterows = movieNotes.grouping(by: { $0.actors }).map { entry in
                    .init(name: entry.key, movies: entry.value.map { $0.title })
            }
            
            Task { @MainActor in
                showLoading = false
            }
        }
    }
}
