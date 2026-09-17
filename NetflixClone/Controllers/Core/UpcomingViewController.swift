//
//  UpcomingViewController.swift
//  NetflixClone
//
//  Created by Ahmed Halilovic on 4. 12. 2023..
//

import UIKit

class UpcomingViewController: UIViewController {

    private var titles: [Title] = []

    private let upcomingTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.separatorStyle = .none
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New & Hot"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

        view.addSubview(upcomingTable)
        upcomingTable.delegate = self
        upcomingTable.dataSource = self

        fetchUpcoming()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        upcomingTable.frame = view.bounds
    }

    private func fetchUpcoming() {
        Task { @MainActor [weak self] in
            do {
                let titles = try await APICaller.shared.titles(for: .upcomingMovies)
                self?.titles = titles
                self?.upcomingTable.reloadData()
            } catch {
                self?.presentErrorAlert(error)
            }
        }
    }
}

extension UpcomingViewController: UITableViewDelegate, UITableViewDataSource {

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
