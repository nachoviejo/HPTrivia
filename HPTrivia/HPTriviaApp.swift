//
//  HPTriviaApp.swift
//  HPTrivia
//
//  Created by Kinamic Kinamic on 22/11/2024.
//

import SwiftUI

@main
struct HPTriviaApp: App {
    @StateObject private var store = Store()
    @StateObject private var game = Game()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(game)
                .task {
                    await store.loadProducts()
                    game.loadScores()
                    store.loadStatus()
                }
        }
    }
}
