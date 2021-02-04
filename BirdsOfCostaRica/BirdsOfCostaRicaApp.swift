//
//  BirdsOfCostaRicaApp.swift
//  BirdsOfCostaRica
//
//  Created by Logan Wright on 2/4/21.
//

import SwiftUI

@main
struct BirdsOfCostaRicaApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .navigationBarTitle(Text("Bird Groups"), displayMode: .inline)
            .accentColor( .black)
        }
    }
}
