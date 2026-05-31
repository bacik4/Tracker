//
//  ViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 18.05.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    // MARK: - Private Methods
    
    private func setupViewControllers() {
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackersNavigationController = UINavigationController(
            rootViewController: trackersViewController
        )
        
        let statisticsNavigationController = UINavigationController(
            rootViewController: statisticsViewController
        )
        
        trackersNavigationController.tabBarItem = makeTabBarItem(
            title: "Трекеры",
            imageName: "record.circle.fill",
        )
        
        statisticsNavigationController.tabBarItem = makeTabBarItem(
            title: "Статистика",
            imageName: "hare.fill",
        )
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
    
    private func makeTabBarItem(
        title: String,
        imageName: String
    ) -> UITabBarItem {
        UITabBarItem(
            title: title,
            image: UIImage(systemName: imageName),
            selectedImage: nil
        )
    }
}

