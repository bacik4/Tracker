//
//  FilterViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 27.06.2026.
//
import UIKit

enum TrackerFilter: Int, CaseIterable {
    case allTrackers
    case trackersForToday
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("allTraсkers", comment: "")
        case .trackersForToday:
            return NSLocalizedString("TrackersForToday", comment: "")
        case .completed:
            return NSLocalizedString("Completed", comment: "")
        case .uncompleted:
            return NSLocalizedString("Uncompleted", comment: "")
        }
    }
}

final class FilterViewController: UIViewController {
    // MARK: - Public Properties

    var selectedFilter: TrackerFilter = .allTrackers
    var onFilterSelected: ((TrackerFilter) -> Void)?
    
    // MARK: - Private Properties
    
    private let tableView = UITableView()
    private let cellIdentifier = "filterCell"
    
    private let filterOptions = TrackerFilter.allCases
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.viewBackground
        setupNavBar()
        setupTableView()
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        title = NSLocalizedString("FilterViewControllerNavBar.title", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.label
        ]
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.backgroundColor = Colors.tableBackgroundColor
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let filter = filterOptions[indexPath.row]
        
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .label
        cell.backgroundColor = Colors.tableBackgroundColor
        cell.selectionStyle = .none
        
        if filter == selectedFilter && filter != .allTrackers && filter != .trackersForToday {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor(resource: .filterButtton)
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filterOptions[indexPath.row]
        
        selectedFilter = filter
        tableView.reloadData()
        
        onFilterSelected?(filter)
        dismiss(animated: true)
    }
}
