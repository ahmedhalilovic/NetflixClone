//
//  DataPersistenceManager.swift
//  NetflixClone
//
//  Created by Net Solution on 18. 12. 2023..
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
    }
    
    static let shared = DataPersistenceManager()
    
    // Let's say we "import" data to the CoreData with this function
    func downloadTitleWith(model: Title, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // "Hey context manager we are creating a title item under your supervision"
        let item = TitleItem(context: context)
        
        item.id = Int64(model.id)
        item.original_title = model.original_title
        item.original_name = model.original_name
        item.title = model.title
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.original_language = model.original_language
        item.vote_average = Double(model.vote_average)
        item.vote_count = Int64(model.vote_count)
        
        // Saving data to the CoreData
        do {
            try context.save()
            completion(.success(())) // It expects Void but swift allows for "()" to be passed
        } catch {
            completion(.failure(DatabaseError.failedToSaveData))
        }
        
    }
    
    // Fetch data/titles from the CoreData
    func fetchingTitlesFromDataBase(completion: @escaping (Result<[TitleItem], Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<TitleItem>
        
        request = TitleItem.fetchRequest()
        
        do {
            
            let titles = try context.fetch(request)
            completion(.success(titles))
            
        } catch {
            completion(.failure(DatabaseError.failedToFetchData))
        }
        
    }
    
    func deleteTitleWith(model: TitleItem, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(model) // asking the database manager to delete certain object
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDeleteData))
        }
        
    }
    
}
