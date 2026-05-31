//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 31.05.2026.
//
import UIKit

final class CategoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavBar()
    }
    
    private func setupNavBar() {
        title = "Категория"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
    }
}
