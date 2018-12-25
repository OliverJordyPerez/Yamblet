// To parse the JSON, add this file to your project and do:
//
//   let series = try? newJSONDecoder().decode(Series.self, from: jsonData)

import Foundation

typealias Series = [SeriesElement]

struct SeriesElement: Codable {
    let show: Show
}

struct Show: Codable {
    let id: Int
    let url: String?
    let name, type, language: String?
    let genres: [String]?
    let premiered: String?
    let schedule: Schedule?
    let network: Network?
    let image: Image?
    let summary: String?
    let officialSite: String?
    
    enum CodingKeys: String, CodingKey {
        case id, url, name, type, language, genres, premiered, schedule, network, image, summary, officialSite
    }
}


struct Image: Codable {
    let medium, original: String
}

struct Previousepisode: Codable {
    let href: String
}

struct Network: Codable {
    let id: Int
    let name: String
    let country: Country
}

struct Country: Codable {
    let name, code, timezone: String
}

struct Schedule: Codable {
    let time: String
    let days: [String]
}
