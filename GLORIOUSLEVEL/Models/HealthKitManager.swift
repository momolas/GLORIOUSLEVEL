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
	
	func getAuthorization() {
		healthStore!.requestAuthorization(toShare: Set([writeType]), read: nil, completion: { (userWasShownPermissionSheet, error) in
			if userWasShownPermissionSheet {
				print("Shown sheet")
				if self.haveAuthorization() {
					print("Have Authorization")
				} else {
					print("Don't have Authorization")
				}
			} else {
				print("Not shown sheet")
			}
		})
	}
	
	func haveAuthorization() -> Bool {
		if isHealthKitAvailable() && healthStore!.authorizationStatus(for: writeType) == .sharingAuthorized {
			return true
		}
		return false
	}
	
	func saveMindfulSession(startTime: Date, endTime: Date) -> Void {
		guard UserDefaults.standard.bool(forKey: "save_healthkit") && self.haveAuthorization() else {
			return
		}
		
		let mindfulSample = HKCategorySample(type: writeType, value: HKCategoryValue.notApplicable.rawValue, start: startTime, end: endTime)
		healthStore!.save(mindfulSample) { (success, error) in
			if error != nil {
				print("Error \(error!)")
			} else {
				print("Saved \(startTime) \(endTime)")
			}
		}
	}
}

