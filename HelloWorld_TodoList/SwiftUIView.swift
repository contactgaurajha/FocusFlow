//
//  SwiftUIView.swift
//  HelloWorld_TodoList
//
//  Created by Gaura Jha on 9/20/25.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var userInput = "" // variable to store user input

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your information:")
                .font(.headline)

            TextField("Type something here...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            
        }
        .padding()
    }
}

#Preview {
    SwiftUIView()
}

