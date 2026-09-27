//
//  ChatService.swift
//  ActivityTrackerIOS
//
//  Created by Alexis Newell on 2026-09-27.
//


final class ChatService {

    // Simulator can access your Mac through 127.0.0.1.
    // Physical iPhone will need your Mac's local IP instead.
    private let baseURL = "http://127.0.0.1:8000"

    func sendMessage(_ message: String) async throws -> ChatResponse {

        guard let url = URL(string: "\(baseURL)/chat") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body = ChatRequest(
            message: message,
            user: UserContext(
                experience: "intermediate",
                goal: "hypertrophy",
                equipment: ["dumbbells", "bench"],
                workout_length: 45
            )
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(
            ChatResponse.self,
            from: data
        )
    }
}