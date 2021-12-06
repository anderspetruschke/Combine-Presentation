//
//  ContentView.swift
//  Shared
//
//  Created by Anders Petruschke on 02.12.21.
//

import SwiftUI

// View gets updated automatically if the emoji list changes
struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TimerView().navigationTitle("Timer")) {
                    Text("Timer")
                }
                NavigationLink(destination: JustView().navigationTitle("Just x 2")) {
                    Text("Just x 2")
                }
                NavigationLink(destination: PokemonView().navigationTitle("Pokemon Searcher")) {
                    Text("Pokemon Searcher")
                }
                NavigationLink(destination: EmojiGridView().navigationTitle("Emoji Receiver").navigationBarTitleDisplayMode(.inline)) {
                    Text("Emoji Receiver")
                }
            }
            .navigationBarTitle("Combine Demo")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


