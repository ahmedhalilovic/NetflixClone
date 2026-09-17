//
//  TitleViewModel.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 11. 12. 2023..
//

import Foundation

/// Lightweight model used by list cells (works for both API titles and Core Data items).
struct TitleViewModel {
    let titleName: String
    let posterURL: URL?
    let releaseYear: String?
    let rating: String?

    init(title: Title) {
        titleName = title.displayTitle
        posterURL = title.posterURL
        releaseYear = title.releaseYear
        rating = title.formattedRating
    }

    init(item: TitleItem) {
        self.init(title: item.asTitle)
    }
}
