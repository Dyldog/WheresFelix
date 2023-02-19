//
//  MovieCalApp.swift
//  MovieCal
//
//  Created by Dylan Elliott on 18/2/2023.
//

import SwiftUI

@main
struct MovieCalApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(viewModel: .init(database: try! .init()))
            }
        }
    }
}
