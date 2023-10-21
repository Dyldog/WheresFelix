//
//  HideView.swift
//  MovieCal
//
//  Created by Dylan Elliott on 20/10/2023.
//

import SwiftUI
import NukeUI
import DylKit

class HideViewModel: ObservableObject, Identifiable {
    let id: UUID = .init()
    
    let database: Database
    let client: MovieClient = .shared
    let onUpdate: () -> Void
    let dismis: () -> Void
    
    var movies: [MovieWithGenres]
    private var genres: [Genre] = []
    
    @Published var movie: MovieWithGenres?
    @Published var people: [Person] = []
    
    init(movies: [MovieWithGenres], database: Database, onUpdate: @escaping () -> Void, dismis: @escaping () -> Void) {
        self.database = database
        self.movies = movies
        self.dismis = dismis
        self.onUpdate = onUpdate
        loadNextMovie()
    }
    
    func loadNextMovie() {
        guard !movies.isEmpty else { return }
        
        let movie = movies.removeFirst()
        
        Task { @MainActor in
            if genres.isEmpty {
                genres = await database.allGenres()
            }
            
            let credited = try! await database.creditsForMovie(movie.movie)
            
            client.getCredits(for: movie.movie) { result in
                guard case let .success(people) = result else { return }
                let others = people.filter { !credited.people.contains($0) }
                
                onMain {
                    self.movie = movie
                    self.people = others
                }
            }
        }
    }
    
    func peopleSelected(_ people: [Person]) {
        people.forEach { person in
            client.getCredits(for: person, genres: genres) { result in
                guard case let .success(movies) = result else { return }
                
                Task { @MainActor in
                    await self.database.createPerson(person, with: movies)
                }
            }
        }
        
        Task { @MainActor in
            await self.database.hideMovie(self.movie!.movie)
            self.onUpdate()
            self.nextMovie()
        }
    }
    
    private func nextMovie() {
        if movies.isEmpty {
            dismis()
        } else {
            loadNextMovie()
        }
    }
}

struct HideView: View {
    @ObservedObject var viewModel: HideViewModel
    
    var body: some View {
        VStack {
            if let movie = viewModel.movie {
                HideMovieView(movie: movie.movie, people: viewModel.people, onSelect: {
                    viewModel.peopleSelected($0)
                })
                .id(movie.id)
            } else {
                ProgressView().progressViewStyle(.circular)
            }
        }
    }
}
struct HideMovieView: View {
    let movie: Movie
    let people: [Person]
    let onSelect: ([Person]) -> Void
    
    @State var selectedPeople: [Int] = []
    
    let columns = Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)
    
    var body: some View {
        HStack {
            LazyImage(url: movie.imageURL)
                .aspectRatio(1.0/1.5, contentMode: .fit)
                .frame(height: 100)
                .cornerRadius(10)
            Text(movie.title)
                .font(.caption).bold()
        }
        .padding()
        
        List {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(people) { person in
                    Button {
                        selectedPeople.toggleMembership(of: person.id)
                    } label: {
                        ZStack {
                            VStack(alignment: .center) {
                                LazyImage(url: person.imageURL)
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
            }
            .padding(.vertical)
        }
        
        Button(action: {
            onSelect(people.filter { self.selectedPeople.contains($0.id) })
        }, label: {
            Text(selectedPeople.isEmpty ? "Skip" : "Add People")
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
        .padding()
    }
}
