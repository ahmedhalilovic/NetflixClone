//
//  CollectionViewTableViewCell.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 5. 12. 2023..
//

import UIKit

protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableViewCell(_ cell: CollectionViewTableViewCell,
                                     didSelect viewModel: TitlePreviewViewModel)
    func collectionViewTableViewCell(_ cell: CollectionViewTableViewCell,
                                     didFailWith error: Error)
}

class CollectionViewTableViewCell: UITableViewCell {

    static let identifier = "CollectionViewTableViewCell"

    weak var delegate: CollectionViewTableViewCellDelegate?

    private var titles: [Title] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 130, height: 195)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self,
                                forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }

    func configure(with titles: [Title]) {
        self.titles = titles
        collectionView.reloadData()
    }

    private func downloadTitle(at indexPath: IndexPath) {
        do {
            try DataPersistenceManager.shared.download(titles[indexPath.row])
        } catch {
            delegate?.collectionViewTableViewCell(self, didFailWith: error)
        }
    }
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let title = titles[indexPath.row]

        // Open the preview even if the trailer lookup fails — it falls back to poster art.
        Task { @MainActor [weak self] in
            let trailer = try? await APICaller.shared.trailer(forTitleNamed: title.displayTitle)
            guard let self else { return }
            self.delegate?.collectionViewTableViewCell(
                self,
                didSelect: TitlePreviewViewModel(title: title, trailer: trailer))
        }
    }

    // Long-press context menu with a Download action.
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }

        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            let downloadAction = UIAction(title: "Download",
                                          image: UIImage(systemName: "arrow.down.circle")) { _ in
                self?.downloadTitle(at: indexPath)
            }
            return UIMenu(options: .displayInline, children: [downloadAction])
        })
    }
}
