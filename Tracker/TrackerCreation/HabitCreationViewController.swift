//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 31.05.2026.
//
import UIKit

final class HabitCreationViewController: UIViewController {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = .black
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let tableView = UITableView()
    private let cellIdentifier = "HabitCreationCell"
    private let tableItems = ["Категория", "Расписание"]
    
    var onCreateTracker: ((Tracker) -> Void)?
    
    private var selectedSchedule: Set<WeekDay> = [] {
        didSet {
            updateCreateButtonState()
            tableView.reloadRows(
                at: [IndexPath(row: 1, section: 0)],
                with: .automatic
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavBar()
        setupTextField()
        setupTableView()
        setupButtons()
    }
    
    private func setupNavBar() {
        title = "Новая привычка"
        
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
    }
    
    private func setupTextField() {
        view.addSubview(textField)
        
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupButtons() {
        view.addSubview(buttonsStackView)
        
        cancelButton.addTarget(
            self,
            action: #selector(didTapCancelButton),
            for: .touchUpInside
        )
        
        createButton.addTarget(
            self,
            action: #selector(didTapCreateButton),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty,
              !selectedSchedule.isEmpty
        else {
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            title: title,
            colour: .systemBlue,
            emoji: "🙂",
            schedule: selectedSchedule
        )
        
        onCreateTracker?(tracker)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }

    private func updateCreateButtonState() {
        let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let canCreate = !title.isEmpty && !selectedSchedule.isEmpty
        
        createButton.isEnabled = canCreate
        createButton.backgroundColor = canCreate ? .black : .systemGray
    }
    
    private func scheduleText() -> String {
        let orderedDays: [WeekDay] = [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday,
            .sunday
        ]
        
        return orderedDays
            .filter { selectedSchedule.contains($0) }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }
}

extension HabitCreationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = tableItems[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black
        
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .systemGray
        
        cell.backgroundColor = .systemGray6
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        if indexPath.row == 1 {
            let text = scheduleText()
            cell.detailTextLabel?.text = text.isEmpty ? nil : text
        } else {
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController()
            let navigationController = UINavigationController(rootViewController: categoryViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true)
        }
        if  indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController(selectedWeekDays: selectedSchedule)
            
            scheduleViewController.onScheduleSelected = { [weak self] weekDays in
                self?.selectedSchedule = weekDays
            }
            
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true)
        }
    }
}
