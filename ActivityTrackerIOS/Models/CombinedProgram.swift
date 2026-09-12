//
//  CombinedProgram.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-08.
//


struct CombinedProgram: Identifiable, Codable {
    var id = UUID()
    var name: String
    var days: [CombinedProgramDay]
}