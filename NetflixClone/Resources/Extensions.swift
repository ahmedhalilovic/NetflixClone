//
//  Extensions.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 7. 12. 2023..
//

import UIKit

extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

extension UIViewController {
    /// Presents a standard alert describing the given error.
    func presentErrorAlert(_ error: Error, title: String = "Something Went Wrong") {
        let alert = UIAlertController(title: title,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
