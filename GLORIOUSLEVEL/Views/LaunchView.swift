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
					.fontWeight(.light)
					.fontDesign(.rounded)
                
                Text("Une application pour faire des exercices de respiration")
                    .font(.caption)
                
                Spacer()
                
				NavigationLink(
					destination: BreathingView(),
					label: {
						Image(systemName: "balloon")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.foregroundColor(.green)
							.frame(width: 200, height: 200)
					}
				)
                
                Spacer()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LaunchView()
        .preferredColorScheme(.dark)
}
