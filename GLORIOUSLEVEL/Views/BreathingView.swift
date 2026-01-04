//
//  ContentView.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 05/10/2022.
//

import SwiftUI

struct BreathingView: View {
	
	@State var breathingViewModel = BreathingViewModel()
    @State var notificationManager = NotificationManager()
	@State var breathingPlanSelection = BreathingPlan.m365
	@State var showSettingsView = false
	
	var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()

            // Ambient Gradient
            RadialGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .black]),
                center: .center,
                startRadius: 5,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                HStack {
                    Menu {
                        ForEach(BreathingPlan.allCases, id: \.self) { plan in
                            Button {
                                breathingPlanSelection = plan
                                breathingViewModel.toggleBreathingPlan(breathingPlanSelected: plan)
                            } label: {
                                if breathingPlanSelection == plan {
                                    Label(plan.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(plan.rawValue)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(breathingPlanSelection.rawValue)
                                .font(.title3)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .bold()
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: .capsule)
                    }

                    Spacer()

                    Button("Settings", systemImage: "gearshape.fill") {
                        self.showSettingsView.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.ultraThinMaterial, in: .circle)
                    .sheet(isPresented: $showSettingsView) {
                        SettingsView(modelData: breathingViewModel, notificationManager: notificationManager, healthkitManager: breathingViewModel.HKManager, showSettingsView: $showSettingsView)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                // Main Content
                VStack(spacing: 40) {
                    Text(breathingViewModel.breathingMessage)
                        .font(.system(size: 32, weight: .light, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .frame(height: 40)

                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 320, height: 320)
                            .blur(radius: 20)

                        // Track
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 4)
                            .frame(width: 300, height: 300)

                        // Breathing Circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 10)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.5), lineWidth: 1)
                            )
                            .scaleEffect(breathingViewModel.getScale(state: breathingViewModel.currentState))
                            .animation(
                                .easeInOut(
                                    duration: Double(
                                        breathingViewModel.currentState == BreathingState.initial ? 3 : breathingViewModel.getDuration(state: breathingViewModel.currentState)
                                    )
                                ),
                                value: breathingViewModel.getScale(state: breathingViewModel.currentState)
                            )

                        // Timer
                        Text(breathingViewModel.timeRemaining, format: .number)
                            .font(.system(size: 80, weight: .thin, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                    .frame(width: 320, height: 320)

                    VStack(spacing: 8) {
                        if breathingViewModel.currentState == .initial {
                            Text("\(breathingViewModel.cycleNumber)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(breathingViewModel.cycleNumber == 1 ? "CYCLE" : "CYCLES")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .tracking(2)
                        } else {
                            Text("\(breathingViewModel.cycleRemaining)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Text(breathingViewModel.cycleRemaining == 1 ? "CYCLE RESTANT" : "CYCLES RESTANTS")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .tracking(2)
                        }
                    }
                }

                Spacer()

                // Footer
                Button(action: {
                    withAnimation {
                        breathingViewModel.startBreathing()
                    }
                }, label: {
                    HStack {
                        Image(systemName: breathingViewModel.currentState != .initial ? "stop.fill" : "play.fill")
                        Text(breathingViewModel.currentState != .initial ? "TERMINER" : "DÉMARRER")
                            .fontWeight(.bold)
                            .tracking(1)
                    }
                    .font(.title3)
                    .foregroundStyle(breathingViewModel.currentState != .initial ? .red : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(breathingViewModel.currentState != .initial ? Color.white : Color.white)
                    .clipShape(.capsule)
                    .shadow(color: .white.opacity(0.2), radius: 20, x: 0, y: 10)
                })
                .padding(.horizontal, 40)
                .padding(.bottom)
            }
        }
        .navigationBarBackButtonHidden(true)
	}
}

#Preview {
	BreathingView(breathingViewModel: BreathingViewModel(), breathingPlanSelection: BreathingPlan.m365, showSettingsView: false)
		.preferredColorScheme(.dark)
}
