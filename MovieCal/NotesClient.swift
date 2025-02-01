//
//  NotesClient.swift
//  MovieCal
//
//  Created by Dylan Elliott on 21/10/2023.
//

import Foundation
import DylKit

struct MovieNote {
    let title: String
    let actors: [String]
    let note: Note
}

extension Note {
    var castLine: String? { contents.components(separatedBy: "\n").first(where: { $0.hasPrefix("cast::")}) }
}

class NotesClient {
    static let shared: NotesClient = .init()
    
    private let notes: NotesDatabase = .init()
    
    var hasSelectedDirectory: Bool { notes.hasSelectedDirectory }
    
    func setDirectory(_ url: URL?) {
        notes.notesDirectoryURL = url
    }
    
    let actorsRegex = try! NSRegularExpression(pattern: "\\[\\[([\\w ]+)\\]\\]", options: [])
    
    func movieNotes() -> [MovieNote] {
        return notes.getNotes(in: "/")?.filter { $0.contents.contains("category:: [[Movies]]") }
            .map {
                .init(
                    title: $0.title,
                    actors: actorsRegex.allMatchGroups(in: $0.castLine ?? ""),
                    note: $0
                )
            } ?? []
    }
}
