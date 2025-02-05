//
//  PeopleView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import Foundation
import SwiftUI
import NukeUI

struct AddedPeopleView: View {
    @StateObject var viewModel: AddedPeopleViewModel
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TextField("Search", text: $viewModel.searchText)
                    .padding()
                peopleList
            }
            
            if viewModel.showLoading {
                loadingIndicator
            }
        }
        .sheet(item: $viewModel.detailViewModel) { model in
            NavigationView {
                PersonDetailView(viewModel: model)
            }
        }
    }
    
    private var peopleList: some View {
        List {
            ForEach(viewModel.peopleRows) { person in
                Button {
                    viewModel.didSelectPerson(person)
                } label: {
                    HStack {
                        LazyImage(url: person.imageURL)
                            .frame(width: 100, height: 150)
                            .cornerRadius(10)
                        VStack {
                            Text(person.title)
                        }
                    }
                }
                .buttonStyle(.plain)
                .swipeActions {
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
