//
//  SearchResultsViewController.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 12. 12. 2023..
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewController(_ controller: SearchResultsViewController,
                                     didSelect viewModel: TitlePreviewViewModel)
}

class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultsViewControllerDelegate?

    private var titles: [Title] = []

    private let searchResultsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self,
                                forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(searchResultsCollectionView)
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsCollectionView.frame = view.bounds
    }

    func update(with titles: [Title]) {
        self.titles = titles
        searchResultsCollectionView.reloadData()
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TitleCollectionViewCell.identifier,
            for: indexPath) as? TitleCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: titles[indexPath.row].posterURL)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3
        let spacing: CGFloat = 8 * (columns - 1) + 12 * 2
        let width = (collectionView.bounds.width - spacing) / columns
        return CGSize(width: width, height: width * 1.5)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let title = titles[indexPath.row]

        Task { @MainActor [weak self] in
            let trailer = try? await APICaller.shared.trailer(forTitleNamed: title.displayTitle)
            guard let self else { return }
            self.delegate?.searchResultsViewController(
                self,
                didSelect: TitlePreviewViewModel(title: title, trailer: trailer))
        }
    }
}
