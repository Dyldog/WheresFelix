//
//  NotesViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation

class PeopleNotesViewModel: NotesViewModel, ObservableObject {
    let notes: NotesClient = .shared
    
    
    var noterows: [NotePersonModel] = []
    
    init() {
        loadNotes()
    }
    
    func onLoadNotes() {
        let movieNotes = notes.movieNotes()
        
        self.noterows = movieNotes.grouping(by: { $0.actors }).map { entry in
            .init(name: entry.key, movies: entry.value.map { $0.title })
        }
    }
}
