//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 19.05.2026.
//
import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Private Properties
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .nothingToAnalyse)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("emptyStateStatistics.title", comment: "Text displayed when you have no statistics")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
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
    
    private let statisticsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let bestPeriodCard = StatisticCardView(value: "0", title: NSLocalizedString("bestPeriod", comment: ""))
    private let idealDaysCard = StatisticCardView(value: "0", title: NSLocalizedString("idealDays", comment: ""))
    private let completedTrackersCard = StatisticCardView(value: "0", title: NSLocalizedString("completedTrackers", comment: ""))
    private let averageCard = StatisticCardView(value: "0", title: NSLocalizedString("avgValue", comment: ""))
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.viewBackground
        
        setupNavBar()
        setupBack()
        setupStatisticsStackView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    // MARK: - Setup
    
    private func setupNavBar() {
        title = NSLocalizedString("StatisticsViewController.title", comment: "Statistics title")
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
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
    
    private func setupStatisticsStackView() {
        view.addSubview(statisticsStackView)
        
        statisticsStackView.addArrangedSubview(bestPeriodCard)
        statisticsStackView.addArrangedSubview(idealDaysCard)
        statisticsStackView.addArrangedSubview(completedTrackersCard)
        statisticsStackView.addArrangedSubview(averageCard)
        
        NSLayoutConstraint.activate([
            statisticsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            bestPeriodCard.heightAnchor.constraint(equalToConstant: 90),
            idealDaysCard.heightAnchor.constraint(equalToConstant: 90),
            completedTrackersCard.heightAnchor.constraint(equalToConstant: 90),
            averageCard.heightAnchor.constraint(equalToConstant: 90),
            
            bestPeriodCard.widthAnchor.constraint(equalTo: statisticsStackView.widthAnchor),
            idealDaysCard.widthAnchor.constraint(equalTo: statisticsStackView.widthAnchor),
            completedTrackersCard.widthAnchor.constraint(equalTo: statisticsStackView.widthAnchor),
            averageCard.widthAnchor.constraint(equalTo: statisticsStackView.widthAnchor)
        ])
    }
    
    // MARK: - Private Methods
    
    private func updateStatistics() {
        let completedTrackersCount = trackerRecordStore.completedTrackersCount()
        let avg = trackerRecordStore.average()
        let bestPeriod = trackerRecordStore.bestPeriod()
        let idealDays = calculateIdealDays()
        
        let hasStatistics = completedTrackersCount > 0
        
        emptyStackView.isHidden = hasStatistics
        statisticsStackView.isHidden = !hasStatistics
        
        completedTrackersCard.configure(value: "\(completedTrackersCount)", title: NSLocalizedString("completedTrackers", comment: ""))
        
        bestPeriodCard.configure(
            value: "\(bestPeriod)",
            title: NSLocalizedString("bestPeriod", comment: "")
        )
        
        idealDaysCard.configure(
            value: "\(idealDays)",
            title: NSLocalizedString("idealDays", comment: "")
        )
        
        averageCard.configure(
            value: "\(avg)",
            title: NSLocalizedString("avgValue", comment: "")
        )
    }
    
    private func calculateIdealDays() -> Int {
        do {
            let trackers = try trackerStore.trackers()
            let records = try trackerRecordStore.records()
            
            let recordsByDate = Dictionary(grouping: records) { record in
                Calendar.current.startOfDay(for: record.date)
            }
            
            var idealDays = 0
            
            for (date, recordsForDate) in recordsByDate {
                let weekDay = weekDay(from: date)
                
                let plannedTrackers = trackers.filter { tracker in
                    tracker.schedule.contains(weekDay)
                }
                
                let plannedTrackerIds = Set(plannedTrackers.map { $0.id })
                let completedTrackerIds = Set(recordsForDate.map { $0.trackerId })
                
                if !plannedTrackerIds.isEmpty &&
                    plannedTrackerIds.isSubset(of: completedTrackerIds) {
                    idealDays += 1
                }
            }
            
            return idealDays
        } catch {
            print("Failed to calculate ideal days: \(error)")
            return 0
        }
    }
    
    private func weekDay(from date: Date) -> WeekDay {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        return WeekDay(rawValue: weekdayNumber) ?? .monday
    }
}
