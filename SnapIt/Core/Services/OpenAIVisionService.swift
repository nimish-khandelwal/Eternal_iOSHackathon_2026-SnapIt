import UIKit

/// Calls OpenAI's chat completions endpoint with an inline base64 image and
/// forces JSON-object output so the response decodes straight into `VisionDetectionResponse`.
final class OpenAIVisionService: VisionService {
    private let apiKey: String
    private let model: String
    private let session: URLSession

    init(apiKey: String = Secrets.openAIAPIKey, model: String = "gpt-4o-mini", session: URLSession = .shared) {
        self.apiKey = apiKey
        self.model = model
        self.session = session
    }

    func detectProducts(in image: UIImage, mode: ScanMode) async throws -> [DetectedProduct] {
        guard let jpegData = image.jpegData(compressionQuality: 0.6) else {
            throw VisionServiceError.invalidImage
        }
        let base64 = jpegData.base64EncodedString()

        let body: [String: Any] = [
            "model": model,
            "response_format": ["type": "json_object"],
            "max_tokens": 500,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": VisionPrompt.prompt(for: mode)],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw VisionServiceError.apiError(String(data: data, encoding: .utf8) ?? "Unknown OpenAI error")
        }

        struct ChatResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String }
                let message: Message
            }
            let choices: [Choice]
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let contentString = decoded.choices.first?.message.content,
              let contentData = contentString.data(using: .utf8) else {
            throw VisionServiceError.invalidResponse
        }

        return try JSONDecoder().decode(VisionDetectionResponse.self, from: contentData).detectedProducts
    }
}
