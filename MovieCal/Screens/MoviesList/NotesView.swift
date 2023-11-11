//
//  NotesView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 21/10/2023.
//

import Foundation
import SwiftUI

struct NotePersonModel: Hashable {
    
    let name: String
    let movies: [String]
}
struct NotesView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.noterows) { person in
                HStack {
                    Text(person.name)
                    
                    VStack {
                        ForEach(person.movies) {
                            Text($0)
                        }
                    }
                }
            }
        }
    }
}
