import Foundation

extension Bundle {
    func decodeJSON<T: Decodable>(_ type: T.Type, from filename: String) throws -> T {
        guard let url = url(forResource: filename, withExtension: nil) else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}
