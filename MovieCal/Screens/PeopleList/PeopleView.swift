//
//  PeopleView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 21/10/2023.
//

import Foundation
import SwiftUI

enum PeopleTab: CaseIterable {
    case added
    case notes
    
    var title: String {
        switch self {
        case .added: return "Added"
        case .notes: return "From Notes"
        }
    }
}

struct PeopleView: View {
    @State var viewModel: PeopleViewModel
    @State var tab: PeopleTab = .added
    
    var body: some View {
        VStack {
            Picker("Tab", selection: $tab) {
                ForEach(PeopleTab.allCases) {
                    Text($0.title).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            currentView
        }
    }
    
    @ViewBuilder
    private var currentView: some View {
        switch tab {
        case .notes:
            PeopleNotesView(viewModel: viewModel.notesViewModel)
        case .added:
            AddedPeopleView(viewModel: viewModel.addedViewModel)
        }
    }
}
