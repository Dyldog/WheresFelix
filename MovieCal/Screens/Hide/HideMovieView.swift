//
//  HideMovieView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 5/2/2025.
//

import SwiftUI
import NukeUI

@MainActor
struct HideMovieView: View {
    let movie: Movie
    let people: [Person]
    let onSelect: ([Person], Bool) -> Void
    
    @State var selectedPeople: [Int] = []
    
    let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)
    
    var body: some View {
        VStack {
            header
            list
            bottomButtons
        }
    }
    
    private var header: some View {
        HStack {
            LazyImage(url: movie.imageURL) { state in
                state.image?.resizable()
            }
            .aspectRatio(1.0/1.5, contentMode: .fit)
            .frame(height: 100)
            .cornerRadius(10)
            Text(movie.title)
                .font(.caption).bold()
        }
        .padding()
    }
    
    private var list: some View {
        List {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(people) { person in
                   cell(for: person)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func cell(for person: Person) -> some View {
        Button {
            selectedPeople.toggleMembership(of: person.id)
        } label: {
            ZStack {
                VStack(alignment: .center) {
                    LazyImage(url: person.imageURL) { state in
                        state.image?.resizable()
                    }
                    .aspectRatio(1.0/1.5, contentMode: .fit)
                    .cornerRadius(10)
                    Text(person.name)
                        .font(.caption).bold()
                }
                
                if selectedPeople.contains(person.id) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                        .font(.largeTitle.bold())
                    
                }
            }
        }
        .buttonStyle(.plain)
    }
    private var bottomButtons: some View {
        HStack {
            bottomButton(title: selectedPeople.isEmpty ? "Skip" : "Don't Hide", color: .red, hide: false)
                .buttonStyle(.bordered)
            bottomButton(title: selectedPeople.isEmpty ? "Hide" : "Add & Hide", color: .blue, hide: true)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func bottomButton(title: String, color: Color, hide: Bool) -> some View {
        Button(action: {
            onSelect(people.filter { self.selectedPeople.contains($0.id) }, hide)
        }, label: {
            Text(title)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
        })
        .tint(color)
        .frame(maxWidth: .infinity)
    }
}
