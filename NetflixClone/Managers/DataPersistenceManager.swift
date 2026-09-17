//
//  DataPersistenceManager.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 18. 12. 2023..
//

import Foundation
import CoreData

extension Notification.Name {
    /// Posted whenever the list of downloaded titles changes.
    static let downloadsDidChange = Notification.Name("DataPersistenceManager.downloadsDidChange")
}

final class DataPersistenceManager {

    enum DatabaseError: LocalizedError {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        case alreadyDownloaded

        var errorDescription: String? {
            switch self {
            case .failedToSaveData: return "The title could not be saved."
            case .failedToFetchData: return "Downloads could not be loaded."
            case .failedToDeleteData: return "The title could not be deleted."
            case .alreadyDownloaded: return "This title is already in your downloads."
            }
        }
    }

    static let shared = DataPersistenceManager()

    private let container: NSPersistentContainer

    private var context: NSManagedObjectContext {
        container.viewContext
    }

    private init() {
        container = NSPersistentContainer(name: "NetflixCloneModel")
        container.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent store: \(error)")
            }
        }
    }

    /// Saves a title to the local downloads store. Throws `.alreadyDownloaded` for duplicates.
    func download(_ title: Title) throws {
        guard try isDownloaded(id: title.id) == false else {
            throw DatabaseError.alreadyDownloaded
        }

        let item = TitleItem(context: context)
        item.id = Int64(title.id)
        item.title = title.title
        item.original_title = title.originalTitle
        item.original_name = title.originalName
        item.original_language = title.originalLanguage
        item.overview = title.overview
        item.poster_path = title.posterPath
        item.release_date = title.releaseDate
        item.vote_average = title.voteAverage ?? 0
        item.vote_count = Int64(title.voteCount ?? 0)

        do {
            try context.save()
        } catch {
            context.rollback()
            throw DatabaseError.failedToSaveData
        }

        NotificationCenter.default.post(name: .downloadsDidChange, object: nil)
    }

    func fetchDownloadedTitles() throws -> [TitleItem] {
        do {
            return try context.fetch(TitleItem.fetchRequest())
        } catch {
            throw DatabaseError.failedToFetchData
        }
    }

    func delete(_ item: TitleItem) throws {
        context.delete(item)
        do {
            try context.save()
        } catch {
            context.rollback()
            throw DatabaseError.failedToDeleteData
        }

        NotificationCenter.default.post(name: .downloadsDidChange, object: nil)
    }

    func isDownloaded(id: Int) throws -> Bool {
        let request = TitleItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        do {
            return try context.count(for: request) > 0
        } catch {
            throw DatabaseError.failedToFetchData
        }
    }
}

extension TitleItem {
    /// Bridges the Core Data item back to the API model so both share the same view models.
    var asTitle: Title {
        Title(id: Int(id),
              title: title,
              originalLanguage: original_language,
              originalTitle: original_title,
              originalName: original_name,
              overview: overview,
              posterPath: poster_path,
              releaseDate: release_date,
              voteAverage: vote_average,
              voteCount: Int(vote_count))
    }
}
