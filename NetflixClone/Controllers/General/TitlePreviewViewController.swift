//
//  TitlePreviewViewController.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 13. 12. 2023..
//

import UIKit
import WebKit
import SDWebImage

/// Shows the trailer (or poster art when no trailer is available) with details and a download action.
class TitlePreviewViewController: UIViewController {

    private var viewModel: TitlePreviewViewModel?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        return webView
    }()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private lazy var downloadButton: UIButton = {
        var config = UIButton.Configuration.prominentGlass()
        config.title = "Download"
        config.image = UIImage(systemName: "arrow.down.to.line")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemRed
        config.cornerStyle = .capsule
        config.buttonSize = .large

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { [weak self] _ in
            self?.downloadTitle()
        }, for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(webView)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(metadataLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(downloadButton)

        configureConstraints()
        applyViewModel()
    }

    private func configureConstraints() {
        let mediaHeight: CGFloat = 260

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: mediaHeight),

            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: mediaHeight),

            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            metadataLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            metadataLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metadataLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            overviewLabel.topAnchor.constraint(equalTo: metadataLabel.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            downloadButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 28),
            downloadButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            downloadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    func configure(with model: TitlePreviewViewModel) {
        viewModel = model
        if isViewLoaded {
            applyViewModel()
        }
    }

    private func applyViewModel() {
        guard let viewModel else { return }

        titleLabel.text = viewModel.title.displayTitle
        overviewLabel.text = viewModel.title.overview

        var metadata: [String] = []
        if let year = viewModel.title.releaseYear { metadata.append(year) }
        if let rating = viewModel.title.formattedRating { metadata.append("★ \(rating)") }
        metadataLabel.text = metadata.joined(separator: "  ·  ")

        if let trailerURL = viewModel.trailerURL {
            webView.isHidden = false
            posterImageView.isHidden = true
            // Embedded via HTML with a YouTube base URL so the player gets a valid
            // referer — loading the embed URL directly fails with player error 153.
            let embedHTML = """
            <!doctype html><html><head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>body{margin:0;background:#000}iframe{border:0;width:100vw;height:100vh}</style>
            </head><body>
            <iframe src="\(trailerURL.absoluteString)" allow="autoplay; encrypted-media" allowfullscreen></iframe>
            </body></html>
            """
            webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://example.com"))
        } else {
            webView.isHidden = true
            posterImageView.isHidden = false
            posterImageView.sd_setImage(with: viewModel.title.posterURL)
        }

        updateDownloadButton()
    }

    private func updateDownloadButton() {
        guard let viewModel else { return }
        if let isDownloaded = try? DataPersistenceManager.shared.isDownloaded(id: viewModel.title.id),
           isDownloaded {
            markAsDownloaded()
        }
    }

    private func markAsDownloaded() {
        var config = downloadButton.configuration
        config?.title = "In Downloads"
        config?.image = UIImage(systemName: "checkmark")
        config?.baseBackgroundColor = .systemGray
        downloadButton.configuration = config
        downloadButton.isEnabled = false
    }

    private func downloadTitle() {
        guard let viewModel else { return }
        do {
            try DataPersistenceManager.shared.download(viewModel.title)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            markAsDownloaded()
        } catch {
            presentErrorAlert(error)
        }
    }
}
