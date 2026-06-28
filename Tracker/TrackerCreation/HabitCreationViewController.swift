//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 31.05.2026.
//
import UIKit

enum TrackerFormMode {
    case create
    case edit(tracker: Tracker, categoryTitle: String, completedDays: Int)
}

private enum TableItem: Int, CaseIterable {
    case category
    case schedule
    
    var title: String {
        switch self {
        case .category: return "Категория"
        case .schedule: return "Расписание"
        }
    }
}

final class HabitCreationViewController: UIViewController {
    // MARK: - Public Properties
    
    var onCreateTracker: ((Tracker, String) -> Void)?
    var onUpdateTracker: ((Tracker, String) -> Void)?
    
    private let mode: TrackerFormMode
    
    // MARK: - Private Properties
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("HabitCreationTextField.placeholder", comment: "HabitCreationTextField")
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
        button.setTitle(NSLocalizedString("cancelButton.title", comment: "cancelButton title"), for: .normal)
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
        button.setTitle(NSLocalizedString("createButton.title", comment: "createButton title"), for: .normal)
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
    
    private var selectedSchedule: Set<WeekDay> = [] {
        didSet {
            updateCreateButtonState()
            tableView.reloadRows(
                at: [IndexPath(row: TableItem.schedule.rawValue, section: 0)],
                with: .automatic
            )
        }
    }
    
    private var selectedCategory: String? {
        didSet {
            updateCreateButtonState()
            tableView.reloadRows(
                at: [IndexPath(row: TableItem.category.rawValue, section: 0)],
                with: .automatic
            )
        }
    }
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emojiLabel", comment: "emojiLabel text")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("colorLabel", comment: "colorLabel text")
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completedDaysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let emojiCellIdentifier = "emojiCell"
    private let colorCellIdentifier = "colorCell"
    
    private let emojies = [ "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let colors: [UIColor] = [
        UIColor(hex: "#FD4C49"),
        UIColor(hex: "#FF881E"),
        UIColor(hex: "#007BFA"),
        UIColor(hex: "#6E44FE"),
        UIColor(hex: "#33CF69"),
        UIColor(hex: "#E66DD4"),
        UIColor(hex: "#F9D4D4"),
        UIColor(hex: "#34A7FE"),
        UIColor(hex: "#46E69D"),
        UIColor(hex: "#35347C"),
        UIColor(hex: "#FF674D"),
        UIColor(hex: "#FF99CC"),
        UIColor(hex: "#F6C48B"),
        UIColor(hex: "#7994F5"),
        UIColor(hex: "#832CF1"),
        UIColor(hex: "#AD56DA"),
        UIColor(hex: "#8D72E6"),
        UIColor(hex: "#2FD058")
    ]
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    init(mode: TrackerFormMode = .create) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavBar()
        setupButtons()
        setupScrollView()
        setupCompletedDaysLabel()
        setupTextField()
        setupTableView()
        setupEmojiLabel()
        setupEmojiColletion()
        setupColorLabel()
        setupColorCollection()
        configureForMode()
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        switch mode {
        case .create:
            title = NSLocalizedString("HabitCreationNavBar.title", comment: "HabitCreationNavBar title")
        case .edit:
            title = NSLocalizedString("EditTrackerNavBar.title", comment: "EditTrackerNavBar title")
        }
        
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
    }
    
    private func setupTextField() {
        contentView.addSubview(textField)
        
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        
        let topAnchor: NSLayoutYAxisAnchor
        let topConstant: CGFloat
        
        switch mode {
        case .create:
            topAnchor = contentView.topAnchor
            topConstant = 24
        case .edit:
            topAnchor = completedDaysLabel.bottomAnchor
            topConstant = 40
        }
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
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
        
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
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
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
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
    
    private func setupEmojiLabel() {
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    private func setupEmojiColletion() {
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.isScrollEnabled = false
        
        contentView.addSubview(emojiCollectionView)
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 0),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204)
        ])
        
        emojiCollectionView.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: emojiCellIdentifier)
    }
    
    private func setupColorLabel() {
        contentView.addSubview(colorLabel)
        
        NSLayoutConstraint.activate([
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
        ])
    }
    
    private func setupColorCollection() {
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.isScrollEnabled = false
        
        contentView.addSubview(colorCollectionView)
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 0),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        colorCollectionView.register(ColorCollectionCell.self,forCellWithReuseIdentifier: colorCellIdentifier)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupCompletedDaysLabel() {
        contentView.addSubview(completedDaysLabel)
        
        NSLayoutConstraint.activate([
            completedDaysLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            completedDaysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func configureForMode() {
        switch mode {
        case .create:
            createButton.setTitle(NSLocalizedString("createButton.title", comment: ""), for: .normal)
            completedDaysLabel.isHidden = true
            
        case let .edit(tracker, categoryTitle, completedDays):
            createButton.setTitle(NSLocalizedString("saveButton.title", comment: ""), for: .normal)
            
            completedDaysLabel.isHidden = false
            completedDaysLabel.text = String.localizedStringWithFormat(
                NSLocalizedString("NumberOfDays", comment: ""),
                completedDays
            )
            
            textField.text = tracker.title
            selectedSchedule = tracker.schedule
            selectedCategory = categoryTitle
            selectedEmoji = tracker.emoji
            
            selectedColor = colors.first {
                $0.hexString() == tracker.color.hexString()
            } ?? tracker.color
            
            tableView.reloadData()
            emojiCollectionView.reloadData()
            colorCollectionView.reloadData()
            updateCreateButtonState()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty,
              !selectedSchedule.isEmpty,
              let selectedEmoji,
              let selectedColor,
              let selectedCategory
        else {
            return
        }
        
        switch mode {
        case .create:
            let tracker = Tracker(
                id: UUID(),
                title: title,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: selectedSchedule
            )

            onCreateTracker?(tracker, selectedCategory)
            
        case let .edit(oldTracker, _, _):
            let updatedTracker = Tracker(
                id: oldTracker.id,
                title: title,
                color: selectedColor,
                emoji: selectedEmoji,
                schedule: selectedSchedule
            )
            
            onUpdateTracker?(updatedTracker, selectedCategory)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let canCreate = !title.isEmpty && !selectedSchedule.isEmpty && selectedEmoji != nil && selectedColor != nil && selectedCategory != nil
        
        createButton.isEnabled = canCreate
        createButton.backgroundColor = canCreate ? .black : .systemGray
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension HabitCreationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        guard let item = TableItem(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .black
        
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .systemGray
        
        cell.backgroundColor = .systemGray6
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        switch item {
        case .category:
            cell.detailTextLabel?.text = selectedCategory
            
        case .schedule:
            let text = scheduleText()
            cell.detailTextLabel?.text = text.isEmpty ? nil : text
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = TableItem(rawValue: indexPath.row) else {
            return
        }
        
        switch item {
        case .category:
            let categoryViewController = CategoryViewController(
                selectedCategoryTitle: selectedCategory
            )
            
            categoryViewController.onCategorySelected = { [weak self] title in
                self?.selectedCategory = title
            }
            
            let navigationController = UINavigationController(rootViewController: categoryViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true)
            
        case .schedule:
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension HabitCreationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojies.count
        } else {
            return colors.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: emojiCellIdentifier,
                for: indexPath
            ) as? EmojiCollectionCell else {
                return UICollectionViewCell()
            }
            
            let emoji = emojies[indexPath.item]
            let isSelected = emoji == selectedEmoji
            
            cell.configure(with: emoji, isSelected: isSelected)
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: colorCellIdentifier,
                for: indexPath
            ) as? ColorCollectionCell else {
                return UICollectionViewCell()
            }
            
            let color = colors[indexPath.item]
            let isSelected = color == selectedColor
            
            cell.configure(with: color, isSelected: isSelected)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojies[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            colorCollectionView.reloadData()
        }
        
        updateCreateButtonState()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HabitCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
}
