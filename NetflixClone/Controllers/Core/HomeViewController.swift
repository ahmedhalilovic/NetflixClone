//
//  HomeViewController.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 4. 12. 2023..
//

import UIKit

class HomeViewController: UIViewController {

    private enum HomeSection: Int, CaseIterable {
        case trendingMovies
        case trendingTV
        case popular
        case upcoming
        case topRated

        var title: String {
            switch self {
            case .trendingMovies: return "Trending Movies"
            case .trendingTV: return "Trending TV"
            case .popular: return "Popular"
            case .upcoming: return "Upcoming Movies"
            case .topRated: return "Top Rated"
            }
        }

        var endpoint: APICaller.TitlesEndpoint {
            switch self {
            case .trendingMovies: return .trendingMovies
            case .trendingTV: return .trendingTV
            case .popular: return .popularMovies
            case .upcoming: return .upcomingMovies
            case .topRated: return .topRatedMovies
            }
        }
    }

    /// Titles per section, fetched once and reused by the cells.
    private var sectionTitles: [HomeSection: [Title]] = [:]

    private var heroTitle: Title?
    private var headerView: HeroHeaderUIView?

    private let homeFeedTable: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(CollectionViewTableViewCell.self,
                       forCellReuseIdentifier: CollectionViewTableViewCell.identifier)
        table.register(UITableViewHeaderFooterView.self,
                       forHeaderFooterViewReuseIdentifier: "SectionHeader")
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(homeFeedTable)
        homeFeedTable.delegate = self
        homeFeedTable.dataSource = self

        configureNavBar()

        let header = HeroHeaderUIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 480))
        header.delegate = self
        headerView = header
        homeFeedTable.tableHeaderView = header

        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction { [weak self] _ in
            self?.fetchAllSections()
        }, for: .valueChanged)
        homeFeedTable.refreshControl = refreshControl

        fetchAllSections()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        homeFeedTable.frame = view.bounds
        // The hero image runs edge-to-edge behind the nav bar, so inset the bottom manually.
        homeFeedTable.contentInset.bottom = view.safeAreaInsets.bottom
    }

    private func configureNavBar() {
        let logoImageView = UIImageView(image: UIImage(named: "NetflixLogo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 30),
            logoImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoImageView)
    }

    /// Fetches every home section concurrently and reloads the feed once.
    private func fetchAllSections() {
        Task { @MainActor [weak self] in
            guard let self else { return }

            var loaded: [HomeSection: [Title]] = [:]
            var lastError: Error?

            await withTaskGroup(of: (HomeSection, Result<[Title], Error>).self) { group in
                for section in HomeSection.allCases {
                    group.addTask {
                        do {
                            let titles = try await APICaller.shared.titles(for: section.endpoint)
                            return (section, .success(titles))
                        } catch {
                            return (section, .failure(error))
                        }
                    }
                }

                for await (section, result) in group {
                    switch result {
                    case .success(let titles): loaded[section] = titles
                    case .failure(let error): lastError = error
                    }
                }
            }

            self.sectionTitles = loaded
            self.configureHeroHeader(with: loaded[.trendingMovies])
            self.homeFeedTable.reloadData()
            self.homeFeedTable.refreshControl?.endRefreshing()

            if loaded.isEmpty, let lastError {
                self.presentErrorAlert(lastError, title: "Could Not Load Titles")
            }

            #if DEBUG
            // Screenshot/UI-test hook: launch with `-autoOpenHeroPreview YES`.
            if UserDefaults.standard.bool(forKey: "autoOpenHeroPreview"), let heroTitle = self.heroTitle {
                self.presentPreview(for: heroTitle)
            }
            #endif
        }
    }

    private func configureHeroHeader(with trending: [Title]?) {
        guard let hero = trending?.randomElement() else { return }
        heroTitle = hero
        headerView?.configure(with: hero)
    }

    private func presentPreview(for title: Title) {
        Task { @MainActor [weak self] in
            let trailer = try? await APICaller.shared.trailer(forTitleNamed: title.displayTitle)
            let vc = TitlePreviewViewController()
            vc.configure(with: TitlePreviewViewModel(title: title, trailer: trailer))
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Home feed table

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        HomeSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CollectionViewTableViewCell.identifier,
                for: indexPath) as? CollectionViewTableViewCell,
              let section = HomeSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.configure(with: sectionTitles[section] ?? [])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader"),
              let homeSection = HomeSection(rawValue: section) else {
            return nil
        }

        var config = UIListContentConfiguration.header()
        config.text = homeSection.title
        config.textProperties.font = .systemFont(ofSize: 18, weight: .semibold)
        config.textProperties.color = .label
        header.contentConfiguration = config
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        16
    }
}

// MARK: - Cell delegate

extension HomeViewController: CollectionViewTableViewCellDelegate {

    func collectionViewTableViewCell(_ cell: CollectionViewTableViewCell,
                                     didSelect viewModel: TitlePreviewViewModel) {
        let vc = TitlePreviewViewController()
        vc.configure(with: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionViewTableViewCell(_ cell: CollectionViewTableViewCell,
                                     didFailWith error: Error) {
        presentErrorAlert(error)
    }
}

// MARK: - Hero header actions

extension HomeViewController: HeroHeaderUIViewDelegate {

    func heroHeaderDidTapPlay(_ headerView: HeroHeaderUIView) {
        guard let heroTitle else { return }
        presentPreview(for: heroTitle)
    }

    func heroHeaderDidTapDownload(_ headerView: HeroHeaderUIView) {
        guard let heroTitle else { return }
        do {
            try DataPersistenceManager.shared.download(heroTitle)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            presentErrorAlert(error)
        }
    }
}
