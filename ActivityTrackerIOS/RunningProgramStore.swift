```swift
//
//  RunningProgramStore.swift
//  ActivityTrackerIOS
//

import Foundation

enum RunningProgramStore {

    private static let storageKey = "running_program_list"

    static func load() -> [RunningProgram] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(
                [RunningProgram].self,
                from: data
            )
        else {
            return []
        }

        return decoded
    }

    static func save(_ programs: [RunningProgram]) {
        guard let data = try? JSONEncoder().encode(programs) else {
            return
        }

        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
```
