//
//  SearchViewController.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 4. 12. 2023..
//

import UIKit

class SearchViewController: UIViewController {

    private var titles: [Title] = []

    /// Pending search request; cancelled whenever the query changes (debounce).
    private var searchTask: Task<Void, Never>?

    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.separatorStyle = .none
        return table
    }()

    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a movie or a TV show"
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

        view.addSubview(discoverTable)
        discoverTable.delegate = self
        discoverTable.dataSource = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self

        fetchDiscoverMovies()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }

    private func fetchDiscoverMovies() {
        Task { @MainActor [weak self] in
            do {
                let titles = try await APICaller.shared.titles(for: .discoverMovies)
                self?.titles = titles
                self?.discoverTable.reloadData()
            } catch {
                self?.presentErrorAlert(error)
            }
        }
    }
}

// MARK: - Discover table

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier,
                                                       for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: TitleViewModel(title: titles[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = titles[indexPath.row]

        Task { @MainActor [weak self] in
            let trailer = try? await APICaller.shared.trailer(forTitleNamed: title.displayTitle)
            let vc = TitlePreviewViewController()
            vc.configure(with: TitlePreviewViewModel(title: title, trailer: trailer))
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - Live search results

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        resultsController.delegate = self

        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespaces)
        searchTask?.cancel()

        guard query.count >= 3 else {
            resultsController.update(with: [])
            return
        }

        searchTask = Task { @MainActor in
            // Small debounce so we don't fire a request per keystroke.
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            do {
                let titles = try await APICaller.shared.titles(for: .search(query: query))
                guard !Task.isCancelled else { return }
                resultsController.update(with: titles)
            } catch {
                // Ignore failed/cancelled queries; the user is still typing.
            }
        }
    }

    func searchResultsViewController(_ controller: SearchResultsViewController,
                                     didSelect viewModel: TitlePreviewViewModel) {
        let vc = TitlePreviewViewController()
        vc.configure(with: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
