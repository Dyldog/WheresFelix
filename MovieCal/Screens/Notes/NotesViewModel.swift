//
//  NotesViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import Foundation
import DylKit
import SwiftUI

protocol NotesViewModel: AnyObject {
    var notes: NotesClient { get }
    
    func onLoadNotes()
}

extension NotesViewModel {
    var showNotes: Bool { !notes.hasSelectedDirectory }
    
    func loadNotes() {
        guard notes.hasSelectedDirectory else { return }
        onLoadNotes()
    }
    
    func didSelectNotesFolder(_ url: URL) {
        notes.setDirectory(url)
        onLoadNotes()
    }
}

struct NotesPresenting: ViewModifier {
    let viewModel: NotesViewModel
    @State var showFileImporter: Bool = false
    
    func body(content: Content) -> some View {
        content.if(viewModel.showNotes) {
            $0.fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.folder]) { result in
                showFileImporter = false
                
                switch result {
                case let .success(url): viewModel.didSelectNotesFolder(url)
                case .failure: break
                }
            }
        }.onAppear {
            showFileImporter = true
        }
    }
}

extension View {
    func notesPresenter(with viewModel: NotesViewModel) -> some View {
        modifier(NotesPresenting(viewModel: viewModel))
    }
}
