//
//  SeasonsData.swift
//  TVSeries
//
//  Created by OliverPérez on 12/24/18.
//  Copyright © 2018 OliverPérez. All rights reserved.
//

import Foundation

typealias Seasons = [SeasonElement]

struct SeasonElement: Codable {

    let name: String
    let season: Int
    let image: ImagePoster?
    let summary: String
    
    enum CodingKeys: String, CodingKey {
        case name, season, image, summary
    }
}

struct ImagePoster: Codable {
    let medium, original: String
}
