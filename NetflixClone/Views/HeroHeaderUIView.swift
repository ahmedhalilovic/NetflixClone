//
//  HeroHeaderUIView.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 5. 12. 2023..
//

import UIKit
import SDWebImage

protocol HeroHeaderUIViewDelegate: AnyObject {
    func heroHeaderDidTapPlay(_ headerView: HeroHeaderUIView)
    func heroHeaderDidTapDownload(_ headerView: HeroHeaderUIView)
}

class HeroHeaderUIView: UIView {

    weak var delegate: HeroHeaderUIViewDelegate?

    private let heroImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "heroImage")
        return imageView
    }()

    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.withAlphaComponent(0.85).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradient.locations = [0.5, 0.85, 1.0]
        return gradient
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // iOS 26 Liquid Glass buttons.
    private lazy var playButton: UIButton = {
        var config = UIButton.Configuration.prominentGlass()
        config.title = "Play"
        config.image = UIImage(systemName: "play.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule
        config.buttonSize = .large

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.heroHeaderDidTapPlay(self)
        }, for: .touchUpInside)
        return button
    }()

    private lazy var downloadButton: UIButton = {
        var config = UIButton.Configuration.glass()
        config.title = "Download"
        config.image = UIImage(systemName: "arrow.down.to.line")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.buttonSize = .large

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.heroHeaderDidTapDownload(self)
        }, for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(heroImageView)
        layer.addSublayer(gradientLayer)
        addSubview(titleLabel)
        addSubview(playButton)
        addSubview(downloadButton)
        applyConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            titleLabel.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -16),

            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            playButton.widthAnchor.constraint(equalTo: downloadButton.widthAnchor),

            downloadButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 12),
            downloadButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            downloadButton.bottomAnchor.constraint(equalTo: playButton.bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.frame = bounds
        gradientLayer.frame = bounds
    }

    func configure(with title: Title) {
        titleLabel.text = title.displayTitle
        heroImageView.sd_setImage(with: title.posterURL,
                                  placeholderImage: UIImage(named: "heroImage"))
    }
}
