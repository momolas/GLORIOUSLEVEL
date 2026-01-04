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
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Ambient Gradient
                LinearGradient(
                    gradient: Gradient(colors: [.black, .blue.opacity(0.3), .purple.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()

                    // Logo / Title Area
                    VStack(spacing: 20) {
                        Image(systemName: "wind")
                            .font(.system(size: 80))
                            .symbolEffect(.breathe)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("GLORIOUSLEVEL")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundStyle(.white)

                        Text("Respiration & Cohérence")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 60)

                    // Cards
                    VStack(spacing: 20) {
                        NavigationLink(value: "breathing") {
                            HStack {
                                Image(systemName: "lungs.fill")
                                    .font(.title2)
                                    .frame(width: 40)

                                VStack(alignment: .leading) {
                                    Text("Respiration")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                    Text("Relaxation & Concentration")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.white)
                        }

                        NavigationLink(value: "heartbeat") {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .font(.title2)
                                    .frame(width: 40)
                                    .foregroundStyle(.red)

                                VStack(alignment: .leading) {
                                    Text("Rythme Cardiaque")
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                    Text("Visualisation des données")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    Text("v1.0.0")
                        .font(.caption2)
                        .foregroundStyle(.secondary.opacity(0.5))
                        .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { value in
                if value == "breathing" {
                    BreathingView()
                } else if value == "heartbeat" {
                    HeartbeatView()
                }
            }
        }
    }
}

#Preview {
    LaunchView()
        .preferredColorScheme(.dark)
}
