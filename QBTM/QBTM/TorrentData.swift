import SwiftUI
import Combine
import Foundation

class TorrentData: ObservableObject {
    @Published var torrents: [Torrent] = []

    struct Torrent: Identifiable {
        let id = UUID()
        let name: String
        let size: Int
        let progress: Double
        let state: String
        let downloaded: Int
        let uploaded: Int
        let dlspeed: Int
        let upspeed: Int
    }

    var sessionCookies: [HTTPCookie]?

    // Step 1: Authenticate with qBittorrent API and Fetch Torrent Data
    func authenticateAndFetchTorrents() {
        guard let address = UserDefaults.standard.string(forKey: "qbAddress"),
              let username = UserDefaults.standard.string(forKey: "qbUsername"),
              let password = UserDefaults.standard.string(forKey: "qbPassword") else {
            print("Missing credentials. Please log in.")
            return
        }

        guard let loginURL = URL(string: "\(address)/api/v2/auth/login") else {
            print("Invalid URL")
            return
        }

        var loginRequest = URLRequest(url: loginURL)
        loginRequest.httpMethod = "POST"
        let postData = "username=\(username)&password=\(password)"
        loginRequest.httpBody = postData.data(using: .utf8)

        URLSession.shared.dataTask(with: loginRequest) { data, response, error in
            if let error = error {
                print("Login request failed with error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let headers = httpResponse.allHeaderFields as? [String: String] {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: loginRequest.url!)
                    self.sessionCookies = cookies
                }
                self.fetchTorrents()
            } else {
                print("Login failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        }.resume()
    }

    // Step 2: Fetch Torrent Data After Authentication
    func fetchTorrents() {
        guard let address = UserDefaults.standard.string(forKey: "qbAddress"),
              let url = URL(string: "\(address)/api/v2/torrents/info") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)

        if let cookies = sessionCookies {
            let cookieHeader = HTTPCookie.requestHeaderFields(with: cookies)
            request.allHTTPHeaderFields = cookieHeader
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch torrents: \(error.localizedDescription)")
                return
            }

            if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        DispatchQueue.main.async {
                            self.torrents = jsonResponse.compactMap { torrent in
                                guard
                                    let name = torrent["name"] as? String,
                                    let size = torrent["total_size"] as? Int,
                                    let progress = torrent["progress"] as? Double,
                                    let state = torrent["state"] as? String,
                                    let downloaded = torrent["downloaded"] as? Int,
                                    let uploaded = torrent["uploaded"] as? Int,
                                    let dlspeed = torrent["dlspeed"] as? Int,
                                    let upspeed = torrent["upspeed"] as? Int
                                else {
                                    return nil
                                }

                                return Torrent(
                                    name: name,
                                    size: size,
                                    progress: progress,
                                    state: state,
                                    downloaded: downloaded,
                                    uploaded: uploaded,
                                    dlspeed: dlspeed,
                                    upspeed: upspeed
                                )
                            }
                        }
                    }
                } catch {
                    print("Failed to decode JSON response: \(error.localizedDescription)")
                }
            } else {
                print("Failed to fetch torrents with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        }.resume()
    }
}
