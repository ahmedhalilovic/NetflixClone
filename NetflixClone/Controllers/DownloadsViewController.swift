//
//  DownloadsViewController.swift
//  NetflixClone
//
//  Created by Net Solution on 4. 12. 2023..
//

import UIKit

class DownloadsViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    

}
