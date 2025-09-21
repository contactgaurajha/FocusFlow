//
//  HelloWorld_TodoListApp.swift
//  HelloWorld_TodoList
//
//  Created by Gaura Jha on 9/20/25.
//

import SwiftUI
import FirebaseCore

@main
struct HelloWorld_TodoListApp: App {
    
    // Initialize Firebase when the app starts
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Login()
        }
    }
}


