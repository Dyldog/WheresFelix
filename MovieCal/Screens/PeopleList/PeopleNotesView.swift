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
struct PeopleNotesView: View {
    @StateObject var viewModel: PeopleNotesViewModel
    
    var body: some View {
        ZStack {
            content
            
            if viewModel.showLoading {
                loadingIndicator
            }
        }
        .notesPresenter(with: viewModel)
    }
    
    private var content: some View {
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
    
    private var loadingIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: 80)
                .aspectRatio(1, contentMode: .fit)
                .opacity(0.9)
            
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}
