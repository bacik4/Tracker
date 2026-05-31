//
//  TrackerCell.swift
//  Tracker
//
//  Created by Игорь Глебов on 30.05.2026.
//
import Foundation
import UIKit

final class TrackerCell: UICollectionViewCell {
    let button = UIButton()
    let label = UILabel()
    let emoji = UILabel()
    let daysLabel = UILabel()
    let colorView = UIView()
    
    var onButtonTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        colorView.layer.cornerRadius = 16
        colorView.layer.masksToBounds = true
        
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        
        emoji.font = .systemFont(ofSize: 16)
        emoji.textAlignment = .center
        emoji.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emoji.layer.cornerRadius = 12
        emoji.layer.masksToBounds = true
        
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .black
        
        contentView.addSubview(colorView)
        colorView.addSubview(label)
        colorView.addSubview(emoji)
        contentView.addSubview(button)
        contentView.addSubview(daysLabel)
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        emoji.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            label.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            emoji.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emoji.widthAnchor.constraint(equalToConstant: 24),
            emoji.heightAnchor.constraint(equalToConstant: 24),
            
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
    
    @objc private func didTapButton() {
        onButtonTap?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onButtonTap = nil
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        label.text = tracker.title
        emoji.text = tracker.emoji
        colorView.backgroundColor = tracker.colour
        button.backgroundColor = tracker.colour
        daysLabel.text = "\(completedDays) дней"
        
        button.setTitle(isCompleted ? "✓" : "+", for: .normal)
        button.alpha = isCompleted ? 0.3 : 1
    }
}
