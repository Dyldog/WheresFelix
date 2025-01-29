//
//  FilterViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

protocol FilterViewModelDelegate {
    func didUpdateMinimumActors(_ newCount: Int)
    func didUpdateSelectedGenres(_ ids: [Int])
}

class FilterViewModel: ObservableObject, Identifiable {
    static let lowestMinimumActorCount = 1
    
    let id: UUID = .init()
    @Published var minimumActors: Int
    var genres: [Genre]
    var delegate: FilterViewModelDelegate
    @Published private var selectedIDs: [Int]
    
    init(minimumActors: Int, genres: [Genre], selectedIDs: [Int], delegate: FilterViewModelDelegate) {
        self.genres = genres.sorted(by: { $0.name < $1.name })
        self.selectedIDs = selectedIDs
        self.minimumActors = max(minimumActors, Self.lowestMinimumActorCount)
        self.delegate = delegate
    }
    
    func isSelected(_ genre: Genre) -> Bool {
        return selectedIDs.contains(genre.id)
    }
    
    func didSelect(_ genre: Genre) {
        if selectedIDs.contains(genre.id) {
            selectedIDs = selectedIDs.filter { $0 != genre.id }
        } else {
            selectedIDs.append(genre.id)
        }
        
        delegate.didUpdateSelectedGenres(selectedIDs)
    }
    
    var minimumActorsTitle: String {
        guard minimumActors >= Self.lowestMinimumActorCount else { return "ERROR" }
        return minimumActors == Self.lowestMinimumActorCount ? "Show all" : "\(minimumActors)"
    }
    
    func didIncreaseMinimumActors() {
        minimumActors = minimumActors + 1
        delegate.didUpdateMinimumActors(minimumActors)
    }
    
    func didDecreaseMinimumActors() {
        minimumActors = max(minimumActors - 1, Self.lowestMinimumActorCount)
        delegate.didUpdateMinimumActors(minimumActors)
    }
}
