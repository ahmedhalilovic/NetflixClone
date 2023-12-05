//
//  Extensions.swift
//  NetflixClone
//
//  Created by Net Solution on 7. 12. 2023..
//

import Foundation


extension String {
    func capitalizedFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
