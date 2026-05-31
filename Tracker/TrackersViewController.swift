//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 19.05.2026.
//
import UIKit

final class TrackersViewController: UIViewController {
    private let searchController = UISearchController()
    private let cellIdentifier = "cell"
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    private var currentDate = Date()
    private var visibleCategories: [TrackerCategory] = []
    
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .backgroundStar)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectonView()
        setupBack()
        updateVisibleCategories()
    }
    
    private func setupNavBar() {
        title = "Трекеры"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self
    }
    
    private func setupBack() {
        view.addSubview(emptyStackView)
        
        emptyStackView.addArrangedSubview(backImageView)
        emptyStackView.addArrangedSubview(backLabel)
        
        NSLayoutConstraint.activate([
            emptyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            
            backImageView.widthAnchor.constraint(equalToConstant: 80),
            backImageView.heightAnchor.constraint(equalToConstant: 80),
            
            backLabel.widthAnchor.constraint(equalToConstant: 343),
            backLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupCollectonView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    @objc private func didTapAddButton() {
        let habitCreationViewController = HabitCreationViewController()
        
        habitCreationViewController.onCreateTracker = { [weak self] tracker in
            self?.addTracker(tracker, to: "Важное")
        }
        
        let navigationController = UINavigationController(rootViewController: habitCreationViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleCategories()
        
    }
    
    private func updateVisibleCategories() {
        let selectedWeekDayNumber = Calendar.current.component(.weekday, from: currentDate)
        
        guard let selectedWeekDay = WeekDay(rawValue: selectedWeekDayNumber) else { return }
        
        let searchText = searchController.searchBar.text?.lowercased() ?? ""
        
        visibleCategories = categories.compactMap { category in
            let visibleTrackers = category.trackers.filter { tracker in
                let isScheduledForSelectedDay = tracker.schedule.contains(selectedWeekDay)
                
                let isMatchingSearch = searchText.isEmpty || tracker.title.lowercased().contains(searchText)
                
                return isScheduledForSelectedDay && isMatchingSearch
            }
            
            if visibleTrackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: visibleTrackers)
        }
        
        let isEmpty = visibleCategories.isEmpty
        emptyStackView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        collectionView.reloadData()
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        completedTrackers.contains { record in
            record.trackerId == tracker.id &&
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func completeTracker(_ tracker: Tracker, on date: Date) {
        guard !isTrackerCompleted(tracker, on: date) else { return }
        
        let trackerRecord = TrackerRecord(
            trackerId: tracker.id,
            date: date
        )
        
        completedTrackers.append(trackerRecord)
    }
    
    private func uncompleteTracker(_ tracker: Tracker, on date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == tracker.id &&
            Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    private func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) {
        if isTrackerCompleted(tracker, on: date) {
            uncompleteTracker(tracker, on: date)
        } else {
            guard !isFutureDate(date) else { return }
            completeTracker(tracker, on: date)
        }
        
    }
    
    private func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let oldCategory = categories[categoryIndex]
            
            let newTrackers = oldCategory.trackers + [tracker]
            
            let newCategory = TrackerCategory(
                title: oldCategory.title,
                trackers: newTrackers
            )
            
            var newCategories = categories
            newCategories[categoryIndex] = newCategory
            
            categories = newCategories
        } else {
            let newCategory = TrackerCategory(
                title: categoryTitle,
                trackers: [tracker]
            )
            
            categories = categories + [newCategory]
        }
        updateVisibleCategories()
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let selectedDate = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        
        return selectedDate > today
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? TrackerCell
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        
        let completedDays = completedTrackers.filter { record in
            record.trackerId == tracker.id
        }.count
        
        cell?.configure(
            with: tracker,
            isCompleted: isCompleted,
            completedDays: completedDays
        )
        
        cell?.onButtonTap = { [weak self] in
            guard let self else { return }
            
            self.toggleTrackerCompletion(tracker, on: self.currentDate)
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        return cell!
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateVisibleCategories()
    }
}
