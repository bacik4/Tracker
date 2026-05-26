//
//  ViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 18.05.2026.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackersNavigationController = UINavigationController(
            rootViewController: trackersViewController
        )
        
        let statisticsNavigationController = UINavigationController(
            rootViewController: statisticsViewController
        )
        
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )
        
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
}

