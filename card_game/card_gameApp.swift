//
//  card_gameApp.swift
//  card_game
//
//  Created by Hao Su on 5/12/21.
//

import SwiftUI

@main
struct card_gameApp: App {
    @StateObject private var currentPlayerCards=cards()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(currentPlayerCards)
        }
    }
}
