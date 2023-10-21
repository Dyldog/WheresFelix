//
//  NotesClient.swift
//  MovieCal
//
//  Created by Dylan Elliott on 21/10/2023.
//

import Foundation
import DylKit

class NotesClient {
    static let shared: NotesClient = .init()
    
    private let notes: NotesDatabase = .init()
    
    var hasSelectedDirectory: Bool { notes.hasSelectedDirectory }
    
    func setDirectory(_ url: URL?) {
        notes.notesDirectoryURL = url
    }
    
    func movieNotes() -> [Note] {
        notes.getNotes(in: "/")?.filter { $0.contents.contains("category:: [[Movies]]") } ?? []
    }
}
