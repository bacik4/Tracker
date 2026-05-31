//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 19.05.2026.
//
import UIKit

final class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Статистика"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
}
