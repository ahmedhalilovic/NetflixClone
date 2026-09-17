//
//  DownloadsViewController.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 4. 12. 2023..
//

import UIKit

class DownloadsViewController: UIViewController {

    private var titles: [TitleItem] = []

    private var downloadsObserver: NSObjectProtocol?

    private let downloadedTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.separatorStyle = .none
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Downloads"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

        view.addSubview(downloadedTable)
        downloadedTable.delegate = self
        downloadedTable.dataSource = self

        fetchDownloads()

        downloadsObserver = NotificationCenter.default.addObserver(
            forName: .downloadsDidChange,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.fetchDownloads()
            }
    }

    deinit {
        if let downloadsObserver {
            NotificationCenter.default.removeObserver(downloadsObserver)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadedTable.frame = view.bounds
    }

    private func fetchDownloads() {
        do {
            titles = try DataPersistenceManager.shared.fetchDownloadedTitles()
            downloadedTable.reloadData()
            updateEmptyState()
        } catch {
            presentErrorAlert(error)
        }
    }

    /// Shows the system empty state when nothing has been downloaded yet.
    private func updateEmptyState() {
        if titles.isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "arrow.down.circle")
            config.text = "No Downloads"
            config.secondaryText = "Movies and shows you download appear here.\nLong-press any poster to download it."
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier,
                                                       for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: TitleViewModel(item: titles[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            do {
                try DataPersistenceManager.shared.delete(self.titles[indexPath.row])
                completion(true)
            } catch {
                self.presentErrorAlert(error)
                completion(false)
            }
        }
        deleteAction.image = UIImage(systemName: "trash")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = titles[indexPath.row].asTitle

        Task { @MainActor [weak self] in
            let trailer = try? await APICaller.shared.trailer(forTitleNamed: title.displayTitle)
            let vc = TitlePreviewViewController()
            vc.configure(with: TitlePreviewViewModel(title: title, trailer: trailer))
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
