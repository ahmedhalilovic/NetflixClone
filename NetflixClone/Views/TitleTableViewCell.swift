//
//  TitleTableViewCell.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 11. 12. 2023..
//

import UIKit
import SDWebImage

class TitleTableViewCell: UITableViewCell {

    static let identifier = "TitleTableViewCell"

    private let titlePosterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.cornerCurve = .continuous
        imageView.backgroundColor = .secondarySystemBackground
        imageView.tintColor = .tertiaryLabel
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 2
        return label
    }()

    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private let playIndicatorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(
            systemName: "play.circle",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.addSubview(titlePosterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(metadataLabel)
        contentView.addSubview(playIndicatorImageView)

        applyConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titlePosterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titlePosterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titlePosterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titlePosterImageView.widthAnchor.constraint(equalToConstant: 90),

            titleLabel.leadingAnchor.constraint(equalTo: titlePosterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: playIndicatorImageView.leadingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -12),

            metadataLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metadataLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            playIndicatorImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            playIndicatorImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titlePosterImageView.sd_cancelCurrentImageLoad()
        titlePosterImageView.image = nil
    }

    func configure(with model: TitleViewModel) {
        titlePosterImageView.sd_setImage(with: model.posterURL,
                                         placeholderImage: UIImage(systemName: "film"))
        titleLabel.text = model.titleName

        var metadata: [String] = []
        if let year = model.releaseYear { metadata.append(year) }
        if let rating = model.rating { metadata.append("★ \(rating)") }
        metadataLabel.text = metadata.joined(separator: "  ·  ")
    }
}
