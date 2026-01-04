//
//  LaunchView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 05/10/2022.
//

// TODO:
// + Export vers Health

import SwiftUI

struct LaunchView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                
                Text("PAINFULDAY")
                    .font(.largeTitle)
                
                Text("Une application pour faire des exercices de respiration")
                    .font(.caption)
                
                Spacer()
                
                NavigationLink(value: "breathing") {
                    Image(systemName: "balloon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.green)
                        .frame(width: 200, height: 200)
                }
                
                Spacer()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { value in
                if value == "breathing" {
                    BreathingView()
                }
            }
        }
    }
}

#Preview {
    LaunchView()
        .preferredColorScheme(.dark)
}
