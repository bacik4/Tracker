//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 31.05.2026.
//
import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - Public Properties
    
    var onScheduleSelected: ((Set<WeekDay>) -> Void)?
    
    // MARK: - Private Properties
    
    private let tableView = UITableView()
    private let cellIdentifier = "DayCell"
    
    private let weekDays: [(title: String, weekDay: WeekDay)] = [
        (NSLocalizedString("monday", comment: ""), .monday),
        (NSLocalizedString("tuesday", comment: ""), .tuesday),
        (NSLocalizedString("wednesday", comment: ""), .wednesday),
        (NSLocalizedString("thursday", comment: ""), .thursday),
        (NSLocalizedString("friday", comment: ""), .friday),
        (NSLocalizedString("saturday", comment: ""), .saturday),
        (NSLocalizedString("sunday", comment: ""), .sunday)
    ]
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle(NSLocalizedString("ScheduleViewController.doneButton", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var selectedWeekDays: Set<WeekDay>
    
    // MARK: - Initializers
    
    init(selectedWeekDays: Set<WeekDay> = []) {
        self.selectedWeekDays = selectedWeekDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavBar()
        setupTableView()
        setupDoneButton()
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        title = NSLocalizedString("ScheduleNavBar.title", comment: "")
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.backgroundColor = .systemGray6
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
            tableView.heightAnchor.constraint(equalToConstant: 75 * 7)
        ])
    }
    
    private func setupDoneButton() {
        view.addSubview(doneButton)
        
        doneButton.addTarget(
            self,
            action: #selector(didTapDoneButton),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didSwitchChanged(_ sender: UISwitch) {
        let weekDay = weekDays[sender.tag].weekDay
        
        if sender.isOn {
            selectedWeekDays.insert(weekDay)
        } else {
            selectedWeekDays.remove(weekDay)
        }
    }
    
    @objc private func didTapDoneButton() {
        onScheduleSelected?(selectedWeekDays)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let item = weekDays[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .systemGray6
        cell.selectionStyle = .none
        
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        switchView.isOn = selectedWeekDays.contains(item.weekDay)
        switchView.onTintColor = .blue
        switchView.addTarget(
            self,
            action: #selector(didSwitchChanged(_:)),
            for: .valueChanged
        )
        
        cell.accessoryView = switchView
        
        return cell
    }
}
