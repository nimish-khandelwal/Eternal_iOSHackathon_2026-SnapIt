import UIKit

/// Calls Gemini's generateContent endpoint with an inline base64 image, requesting
/// application/json output so the response decodes straight into `VisionDetectionResponse`.
final class GeminiVisionService: VisionService {
    private let apiKey: String
    private let model: String
    private let session: URLSession

    init(apiKey: String = Secrets.geminiAPIKey, model: String = "gemini-3-flash-preview", session: URLSession = .shared) {
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
            "contents": [
                [
                    "parts": [
                        ["text": VisionPrompt.prompt(for: mode)],
                        ["inline_data": ["mime_type": "image/jpeg", "data": base64]]
                    ]
                ]
            ],
            "generationConfig": ["response_mime_type": "application/json"]
        ]

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw VisionServiceError.apiError(String(data: data, encoding: .utf8) ?? "Unknown Gemini error")
        }

        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates.first?.content.parts.first?.text,
              let contentData = text.data(using: .utf8) else {
            throw VisionServiceError.invalidResponse
        }

        return try JSONDecoder().decode(VisionDetectionResponse.self, from: contentData).detectedProducts
    }
}
