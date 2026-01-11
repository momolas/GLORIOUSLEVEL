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
			try await healthStore.requestAuthorization(toShare: [writeType], read: allType)
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

    // MARK: - Heart Rate

    var currentHeartRate: Double = 0
    private var heartRateQuery: HKQuery?

    func startHeartRateQuery() {
        guard isHealthKitAvailable(),
              let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let startDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, _, _, _ in
            Task {
                await self?.processHeartRateSamples(samples, from: query)
            }
        }

        query.updateHandler = { [weak self] query, samples, _, _, _ in
            Task {
                await self?.processHeartRateSamples(samples, from: query)
            }
        }

        healthStore?.execute(query)
        heartRateQuery = query
    }

    func stopHeartRateQuery() {
        if let query = heartRateQuery {
            healthStore?.stop(query)
            heartRateQuery = nil
        }
        currentHeartRate = 0
    }

    private func processHeartRateSamples(_ samples: [HKSample]?, from query: HKQuery) async {
        guard query == self.heartRateQuery,
              let samples = samples as? [HKQuantitySample],
              let lastSample = samples.last else {
            return
        }

        let heartRate = lastSample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
        self.currentHeartRate = heartRate
    }
}
