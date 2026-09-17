//
//  TitleCollectionViewCell.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 11. 12. 2023..
//

import UIKit
import SDWebImage

class TitleCollectionViewCell: UICollectionViewCell {

    static let identifier = "TitleCollectionViewCell"

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.cornerCurve = .continuous
        imageView.backgroundColor = .secondarySystemBackground
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(posterImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        posterImageView.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.sd_cancelCurrentImageLoad()
        posterImageView.image = nil
    }

    func configure(with posterURL: URL?) {
        posterImageView.sd_setImage(with: posterURL,
                                    placeholderImage: UIImage(systemName: "film"))
    }
}
