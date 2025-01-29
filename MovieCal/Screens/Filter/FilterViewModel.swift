//
//  FilterViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

protocol FilterViewModelDelegate {
    func didUpdateFilter(_ model: FilterViewModel)
}

class FilterViewModel: ObservableObject, Identifiable {
    static let lowestMinimumActorCount = 1
    
    let id: UUID = .init()
    @Published private(set) var minimumActors: Int
    @Published private(set) var hideUnreleased: Bool
    private(set) var genres: [Genre]
    @Published private(set)var excludeGenres: Bool
    var delegate: FilterViewModelDelegate
    @Published private(set) var selectedIDs: [Int]
    
    init(minimumActors: Int, hideUnreleased: Bool, genres: [Genre], selectedIDs: [Int], excludeGenres: Bool, delegate: FilterViewModelDelegate) {
        self.genres = genres.sorted(by: { $0.name < $1.name })
        self.selectedIDs = selectedIDs
        self.excludeGenres = excludeGenres
        self.minimumActors = max(minimumActors, Self.lowestMinimumActorCount)
        self.hideUnreleased = hideUnreleased
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
        
        delegate.didUpdateFilter(self)
    }
    
    var minimumActorsTitle: String {
        guard minimumActors >= Self.lowestMinimumActorCount else { return "ERROR" }
        return minimumActors == Self.lowestMinimumActorCount ? "Show all" : "\(minimumActors)"
    }
    
    func didIncreaseMinimumActors() {
        minimumActors = minimumActors + 1
        delegate.didUpdateFilter(self)
    }
    
    func didDecreaseMinimumActors() {
        minimumActors = max(minimumActors - 1, Self.lowestMinimumActorCount)
        delegate.didUpdateFilter(self)
    }
    
    func didSetHideUnreleased(_ newValue: Bool) {
        hideUnreleased = newValue
        delegate.didUpdateFilter(self)
    }
    
    func didSetExcludeGenres(_ newValue: Bool) {
        excludeGenres = newValue
        delegate.didUpdateFilter(self)
    }
}
