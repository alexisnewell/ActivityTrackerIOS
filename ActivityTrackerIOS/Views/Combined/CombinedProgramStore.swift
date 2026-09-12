//
//  CombinedProgramStore.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-09.
//


//
//  CombinedProgramStore.swift
//

import Foundation

enum CombinedProgramStore {

    private static let storageKey = "combinedPrograms"

    static func load() -> [CombinedProgram] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([CombinedProgram].self, from: data)
        } catch {
            print("CombinedProgramStore: failed to decode saved programs — \(error)")
            return []
        }
    }

    static func save(_ programs: [CombinedProgram]) {
        do {
            let data = try JSONEncoder().encode(programs)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("CombinedProgramStore: failed to encode programs for saving — \(error)")
        }
    }
}