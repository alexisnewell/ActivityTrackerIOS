//
//  ShareSheet.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-08-03.
//


import SwiftUI
import UIKit

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
