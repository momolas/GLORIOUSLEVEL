//
//  ViewModel.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 05/10/2022.
//

import Foundation
import SwiftUI
import HealthKit
import Observation

enum BreathingPlan: String, CaseIterable {
	case mwh = "Wim Hof"
	case m365 = "365"
	case m4x4 = "4x4"
	
	var description: String {
		switch self {
		case .mwh:
			return "Méthode Wim Hof"
		case .m365:
			return "Méthode 365"
		case .m4x4:
			return "Méthode 4x4"
		}
	}
	
	struct BreathingTimes {
		let inhale: Int
		let hold: Int
		let reps: Int
	}

	var details: BreathingTimes {
		switch self {
		case .mwh:
			return BreathingTimes(inhale: 5, hold: 60, reps: 30)
		case .m365:
			return BreathingTimes(inhale: 5, hold: 0, reps: 6)
		case .m4x4:
			return BreathingTimes(inhale: 5, hold: 5, reps: 10)
		}
	}
}

struct TimeConstants {
	static let defaultTensionTime = 5
	static let defaultRelaxTime = 10
	static let defaultTotalReps = 10
}

enum BreathingState: CaseIterable {
	case initial
	case inhaling
	case exhaling
	case holding
}

@Observable
@MainActor
class BreathingViewModel {
	
	var breathingState: BreathingState = .initial
	var breathingPlan: BreathingPlan = .m365
	var currentState = BreathingState.initial
	var previousState = BreathingState.initial
	
	var breathingMessage: String {
		switch currentState {
			case .initial:
				return "Commençons !"
			case .inhaling:
				return "Inspirez"
			case .exhaling:
				return "Expirez"
			case .holding:
				return "Bloquez !"
		}
	}
	
	
	var isVibration: Bool = true
	
	var inhaleTime : Int {
		breathingPlan.details.inhale
	}
	
	var holdTime : Int {
		breathingPlan.details.hold
	}
	
	var cycleNumber : Int {
		breathingPlan.details.reps
	}
	
	var timeRemaining = 0
	var cycleRemaining = 0
	
	private var timerTask: Task<Void, Never>?
	
	private(set) var elapsedTime: Double = 0.0
	private(set) var progress: Double = 0.0
	
	let HKManager = HealthKitManager()
	
	private var mindfulSessionDuration = 0
	
	func toggleBreathingPlan(breathingPlanSelected: BreathingPlan) {
		if breathingPlanSelected == .mwh {
			breathingPlan = .mwh
		} else if breathingPlanSelected == .m365 {
			breathingPlan = .m365
		} else {
			breathingPlan = .m4x4
		}
	}
	
	func getDuration(state: BreathingState) -> Int {
		switch state {
		case .inhaling:
			return inhaleTime
		case .holding:
			return holdTime
		case .exhaling:
			return inhaleTime
		default:
			return 3
		}
	}
	
	func getScale(state: BreathingState) -> Double {
		switch state {
		case .inhaling:
			return 3
		case .holding:
			if previousState == .inhaling {
				return 3
			} else {
				return 0.7
			}
		case .exhaling:
			return 0.7
		default:
			return 1.0
		}
	}
	
	func startTimer() {
		stopTimer()
		timerTask = Task { [weak self] in
			let interval = Duration.seconds(1)
			var nextTick = ContinuousClock.now + interval

			while !Task.isCancelled {
				try? await Task.sleep(until: nextTick, clock: .continuous)
				if Task.isCancelled { break }
				self?.trackBreathing()
				nextTick += interval

				let now = ContinuousClock.now
				if nextTick < now {
					nextTick = now + interval
				}
			}
		}
	}
	
	func stopTimer() {
		timerTask?.cancel()
		timerTask = nil
	}
	
	func trackBreathing() {
		if currentState == .initial {
			return
		}
		
		mindfulSessionDuration += 1
		
		if timeRemaining > 0 {
			timeRemaining -= 1
			sendSoftFeedback()
		}
		
		if timeRemaining == 0 {
			sendHeavyFeedback()
			
			switch breathingPlan {
			case .m4x4:
				switch currentState {
				case .inhaling:
					currentState = .holding
					previousState = .inhaling
				case .exhaling:
					currentState = .holding
					previousState = .exhaling
				case .holding:
					if previousState == .inhaling {
						currentState = .exhaling
					} else {
						cycleRemaining -= 1
						if cycleRemaining == 0 {
							currentState = .initial
							stopTimer()
							sendHeavyFeedback()
							return
						} else {
							currentState = .inhaling
						}
					}
				case .initial:
					return
				}
				
			case .m365:
				switch currentState {
				case .inhaling:
					currentState = .exhaling
				case .holding:
					return
				case .exhaling:
					cycleRemaining -= 1
					if cycleRemaining == 0 {
						currentState = .initial
						stopTimer()
						sendHeavyFeedback()
						return
					} else {
						currentState = .inhaling
					}
				case .initial:
					return
				}
				
			case .mwh:
				switch currentState {
				case .inhaling:
					currentState = .exhaling
				case .holding:
					currentState = .initial
					stopTimer()
					sendHeavyFeedback()
					return
				case .exhaling:
					cycleRemaining -= 1
					if cycleRemaining == 0 {
						currentState = .holding
					} else {
						currentState = .inhaling
					}
				case .initial:
					return
				}
			}
			
			timeRemaining = getDuration(state: currentState)
			elapsedTime += 1
			let totalTime = breathingState == .inhaling ? inhaleTime : inhaleTime
			progress = (elapsedTime / Double(totalTime) * 100).rounded() / 100
		}
	}
	
	func startBreathing() {
		if currentState == .initial {
			currentState = .inhaling
			timeRemaining = getDuration(state: currentState)
			cycleRemaining = cycleNumber
			startTimer()
		} else {
			currentState = .initial
			timeRemaining = 0
			stopTimer()
		}
	}
	
	func sendSoftFeedback() {
		guard UserDefaults.standard.bool(forKey: "reduce_haptics") == false else {
			return
		}
		
		let impactSoft = UIImpactFeedbackGenerator(style: .soft)
		impactSoft.impactOccurred()
	}
	
	func sendHeavyFeedback() {
		guard UserDefaults.standard.bool(forKey: "reduce_haptics") == false else {
			return
		}
		
		let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
		impactHeavy.impactOccurred()
	}
	
	func simpleSuccess() {
		let generator = UINotificationFeedbackGenerator()
		generator.notificationOccurred(.success)
	}
	
	func saveToHealthKit() {
		let startTime = Date(timeIntervalSinceNow: Double(-mindfulSessionDuration))
		let endTime = Date()
		Task {
			await HKManager.saveMindfulSession(startTime: startTime, endTime: endTime)
		}
		mindfulSessionDuration = 0
	}

	@MainActor deinit {
		timerTask?.cancel()
	}
}

