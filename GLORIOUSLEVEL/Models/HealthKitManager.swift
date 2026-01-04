//
//  File.swift
//  GLORIOUSLEVEL
//
//  Created by Mo on 09/10/2022.
//

import Foundation
import HealthKit
import Observation

@Observable
@MainActor
class HealthKitManager {
	
	var healthStore: HKHealthStore? = HKHealthStore()
	private let writeType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
	private let allType = Set([
		HKSeriesType.heartbeat(),
		HKObjectType.quantityType(forIdentifier: .heartRate)!,
		HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
	])
	
	init() {
		if HKHealthStore.isHealthDataAvailable() {
			healthStore = HKHealthStore()
		}
	}
	
	func isHealthKitAvailable() -> Bool {
		return HKHealthStore.isHealthDataAvailable()
	}
	
	func getAuthorization() async {
		guard let healthStore else { return }
		do {
			try await healthStore.requestAuthorization(toShare: Set([writeType]), read: allType)
			// print("Authorization requested")
		} catch {
			// print("Error requesting authorization: \(error)")
		}
	}
	
	func haveAuthorization() -> Bool {
		if isHealthKitAvailable() && healthStore!.authorizationStatus(for: writeType) == .sharingAuthorized {
			return true
		}
		return false
	}
	
	func saveMindfulSession(startTime: Date, endTime: Date) async {
		guard UserDefaults.standard.bool(forKey: "save_healthkit") && self.haveAuthorization() else {
			return
		}
		
		let mindfulSample = HKCategorySample(type: writeType, value: HKCategoryValue.notApplicable.rawValue, start: startTime, end: endTime)

		do {
			try await healthStore?.save(mindfulSample)
			// print("Saved \(startTime) \(endTime)")
		} catch {
			// print("Error \(error)")
		}
	}
}
