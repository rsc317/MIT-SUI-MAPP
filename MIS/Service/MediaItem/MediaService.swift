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

    func downloadMedia(id: Int) async throws -> Data {
        let url = baseURL.appendingPathComponent("/media/\(id)/download")
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    func updateMedia(mediaID: Int, fileData: Data, fileURL: URL) async throws {
        let filename = fileURL.lastPathComponent
        let mimetype = MimeType.from(url: fileURL).rawValue

        var request = URLRequest(url: baseURL.appendingPathComponent("/media/\(mediaID)"))
        request.httpMethod = "PUT"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        let (_, response) = try await URLSession.shared.upload(for: request, from: body)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "UpdateError", code: 0)
        }
    }

    func deleteMedia(id: Int) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("/media/\(id)"))
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "DeleteError", code: 0)
        }
    }

    // MARK: - Private

    private var baseURL: URL {
        let ip = UserDefaults.standard.string(forKey: UserDefaultKeys.ipAddress) ?? "127.0.0.1"
        let port = UserDefaults.standard.string(forKey: UserDefaultKeys.port) ?? "8000"
        let urlString = "http://\(ip):\(port)"
        return URL(string: urlString) ?? URL(string: "http://127.0.0.1:8000")!
    }
}
