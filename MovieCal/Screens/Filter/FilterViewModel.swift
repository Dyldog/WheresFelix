//
//  FilterViewModel.swift
//  MovieCal
//
//  Created by Dylan Elliott on 19/2/2023.
//

import Foundation

protocol FilterViewModelDelegate {
    func didUpdateSelectedGenres(_ ids: [Int])
}

class FilterViewModel: ObservableObject {
    var genres: [MovieGenre]
    var delegate: FilterViewModelDelegate
    @Published private var selectedIDs: [Int]
    
    init(genres: [MovieGenre], selectedIDs: [Int], delegate: FilterViewModelDelegate) {
        self.genres = genres.sorted(by: { $0.name < $1.name })
        self.selectedIDs = selectedIDs
        self.delegate = delegate
    }
    
    func isSelected(_ genre: MovieGenre) -> Bool {
        return selectedIDs.contains(genre.id)
    }
    
    func didSelect(_ genre: MovieGenre) {
        if selectedIDs.contains(genre.id) {
            selectedIDs = selectedIDs.filter { $0 != genre.id }
        } else {
            selectedIDs.append(genre.id)
        }
        
        delegate.didUpdateSelectedGenres(selectedIDs)
    }
}
