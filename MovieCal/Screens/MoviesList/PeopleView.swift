//
//  PeopleView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import NukeUI

struct PeopleView: View {
    @ObservedObject var viewModel: ContentViewModel
    var body: some View {
        List {
            ForEach(viewModel.peopleRows) { person in
                HStack {
                    LazyImage(url: person.imageURL)
                        .frame(width: 100, height: 150)
                        .cornerRadius(10)
                    VStack {
                        Text(person.title)
                    }
                }.swipeActions {
                    Button {
                        viewModel.deletePerson(person)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
        }
    }
}
