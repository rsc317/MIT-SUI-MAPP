import Foundation

class MediaService: MediaServiceProtocol {

    // MARK: - Internal

    static let shared = MediaService()

    func uploadMedia(data: Data, fileURL: URL) async throws -> Int {
        let filename = fileURL.lastPathComponent
        let mimetype = MimeType.from(url: fileURL).rawValue

        var request = URLRequest(url: baseURL.appendingPathComponent("/upload"))
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let (data, _) = try await URLSession.shared.upload(for: request, from: body)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let id = json["id"] as? Int else {
            throw NSError(domain: "UploadError", code: 0, userInfo: nil)
        }

        return id
    }

    func fetchMetadata(for id: Int) async throws -> [String: Any] {
        let url = baseURL.appendingPathComponent("/media/\(id)")
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "MetadataError", code: 0)
        }

        return json
    }

    func downloadMedia(id: Int) async throws -> Data {
        let url = baseURL.appendingPathComponent("/media/\(id)/download")
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    func updateMedia(mediaID: Int, fileData: Data, filename: String, mimeType: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("/media/\(mediaID)"))
        request.httpMethod = "PUT"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let (_, response) = try await URLSession.shared.upload(for: request, from: body)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "UpdateError", code: 0)
        }
    }

    // MARK: - Private

    private let baseURL = URL(string: "http://192.168.0.91:8000")!
}
