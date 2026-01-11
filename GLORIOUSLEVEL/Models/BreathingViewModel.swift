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
    case nox = "NOx"
    case recovery = "Recovery"
    case light = "Light"
	
	var description: String {
		switch self {
		case .mwh:
			return "Méthode Wim Hof"
		case .m365:
			return "Méthode 365"
		case .m4x4:
			return "Méthode 4x4"
        case .nox:
            return "Méthode NOx"
        case .recovery:
            return "Buteyko Récupération"
        case .light:
            return "Buteyko Léger"
		}
	}
	
	struct BreathingTimes {
		let inhale: Int
		let holdFull: Int
        let exhale: Int
        let holdEmpty: Int
		let reps: Int
	}

	var details: BreathingTimes {
		switch self {
		case .mwh:
            // Wim Hof: Inhale/Exhale 5s, Hold 60s at end.
			return BreathingTimes(inhale: 5, holdFull: 0, exhale: 5, holdEmpty: 60, reps: 30)
		case .m365:
            // 365: Inhale 5, Exhale 5. No holds.
			return BreathingTimes(inhale: 5, holdFull: 0, exhale: 5, holdEmpty: 0, reps: 6)
		case .m4x4:
            // Box: 5-5-5-5.
			return BreathingTimes(inhale: 5, holdFull: 5, exhale: 5, holdEmpty: 5, reps: 10)
        case .nox:
            // NOx: Inhale 4, Hold 4, Exhale 6, Hold 2.
            return BreathingTimes(inhale: 4, holdFull: 4, exhale: 6, holdEmpty: 2, reps: 6)
        case .recovery:
            // Recovery: Inhale 5, Exhale 5 (Relaxed breathing) -> Hold 5 (Pinch nose).
            return BreathingTimes(inhale: 5, holdFull: 0, exhale: 5, holdEmpty: 5, reps: 20)
        case .light:
            // Light: Inhale 4, Exhale 6. Gentle reduced breathing.
            return BreathingTimes(inhale: 4, holdFull: 0, exhale: 6, holdEmpty: 0, reps: 30)
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
    case holdFull
    case holdEmpty
}

@Observable
@MainActor
class BreathingViewModel {
	
	var breathingPlan: BreathingPlan = .m365
	var currentState: BreathingState = .initial
	
	var breathingMessage: String {
		switch currentState {
			case .initial:
				return "Commençons !"
			case .inhaling:
                if breathingPlan == .light || breathingPlan == .recovery {
                    return "Inspirez (Normal)"
                }
				return "Inspirez"
			case .exhaling:
                if breathingPlan == .nox {
                    return "Expirez (Mmm)"
                }
                if breathingPlan == .light || breathingPlan == .recovery {
                    return "Expirez (Normal)"
                }
				return "Expirez"
			case .holdFull, .holdEmpty:
                if breathingPlan == .recovery && currentState == .holdEmpty {
                    return "Pincez le nez !"
                }
				return "Bloquez !"
		}
	}
	
	var inhaleTime : Int {
		breathingPlan.details.inhale
	}
	
    // Legacy support or specific holds
    var holdFullTime : Int {
        breathingPlan.details.holdFull
    }

    var exhaleTime : Int {
        breathingPlan.details.exhale
    }

    var holdEmptyTime : Int {
        breathingPlan.details.holdEmpty
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
		breathingPlan = breathingPlanSelected
	}
	
	func getDuration(state: BreathingState) -> Int {
		switch state {
		case .inhaling:
			return inhaleTime
        case .holdFull:
            return holdFullTime
		case .exhaling:
			return exhaleTime
        case .holdEmpty:
            return holdEmptyTime
		default:
			return 3
		}
	}
	
	func getScale(state: BreathingState) -> Double {
		switch state {
		case .inhaling, .holdFull:
			return 1.2
		case .exhaling, .holdEmpty:
			return 0.8
		default:
			return 0.8
		}
	}

	func getOpacity(state: BreathingState) -> Double {
		switch state {
		case .inhaling, .holdFull:
			return 0.3
		case .exhaling, .holdEmpty:
			return 1.0
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
			case .m4x4, .nox, .recovery, .m365, .light:
                advanceState()
				
			case .mwh:
                // Inhale -> Exhale -> (repeat) -> HoldEmpty (long) -> Finish
				switch currentState {
				case .inhaling:
					currentState = .exhaling
                case .exhaling:
					cycleRemaining -= 1
					if cycleRemaining == 0 {
						currentState = .holdEmpty
					} else {
						currentState = .inhaling
					}
				case .holdEmpty:
					currentState = .initial
					stopTimer()
					sendHeavyFeedback()
					HKManager.stopHeartRateQuery()
					return
				case .initial:
					return
                default: break
				}
			}
			
			timeRemaining = getDuration(state: currentState)
			elapsedTime += 1
            // Progress calculation needs total time per cycle? Or simplified.
            // Keeping it simple relative to inhale time for now or total duration.
			let totalTime = getDuration(state: currentState)
			progress = (elapsedTime / Double(totalTime) * 100).rounded() / 100
            if progress > 1.0 { progress = 0 } // Reset logic simplified
		}
	}
	
	func startBreathing() {
		if currentState == .initial {
			currentState = .inhaling
			timeRemaining = getDuration(state: currentState)
			cycleRemaining = cycleNumber
			startTimer()
			HKManager.startHeartRateQuery()
		} else {
			currentState = .initial
			timeRemaining = 0
			stopTimer()
			HKManager.stopHeartRateQuery()
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

    private func advanceState() {
        switch currentState {
        case .inhaling:
            if holdFullTime > 0 {
                currentState = .holdFull
            } else {
                currentState = .exhaling
            }
        case .holdFull:
            currentState = .exhaling
        case .exhaling:
            if holdEmptyTime > 0 {
                currentState = .holdEmpty
            } else {
                completeCycle()
            }
        case .holdEmpty:
            completeCycle()
        default:
            break
        }
    }

	private func completeCycle() {
		cycleRemaining -= 1
		if cycleRemaining == 0 {
			currentState = .initial
			stopTimer()
			sendHeavyFeedback()
			HKManager.stopHeartRateQuery()
		} else {
			currentState = .inhaling
		}
	}

	@MainActor deinit {
		timerTask?.cancel()
	}
}

