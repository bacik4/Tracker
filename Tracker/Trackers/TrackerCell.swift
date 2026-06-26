//
//  TrackerCell.swift
//  Tracker
//
//  Created by Игорь Глебов on 30.05.2026.
//
import UIKit

final class TrackerCell: UICollectionViewCell {
    // MARK: - Public Properties
    
    var onButtonTap: (() -> Void)?
    
    // MARK: - Private Properties
    
    private let button = UIButton()
    private let label = UILabel()
    private let emoji = UILabel()
    private let daysLabel = UILabel()
    private let colorView = UIView()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        setupViews()
        setupLayout()
        setupActions()
    }
    
    private func setupViews() {
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
        
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        
        daysLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysLabel.textColor = .black
    }
    
    private func setupLayout() {
        contentView.addSubview(colorView)
        colorView.addSubview(label)
        colorView.addSubview(emoji)
        contentView.addSubview(button)
        contentView.addSubview(daysLabel)
        
        [colorView, emoji, label, button, daysLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
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
    
    private func setupActions() {
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapButton() {
        onButtonTap?()
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onButtonTap = nil
    }
    
    // MARK: - Configuration
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int) {
        label.text = tracker.title
        emoji.text = tracker.emoji
        colorView.backgroundColor = tracker.color
        button.backgroundColor = tracker.color
        
        updateCompletion(isCompleted: isCompleted, completedDays: completedDays)
    }
    
    func updateCompletion(isCompleted: Bool, completedDays: Int) {
        daysLabel.text = String.localizedStringWithFormat(NSLocalizedString("NumberOfDays", comment: "Days record"), completedDays)
        
        let imageName = isCompleted ? "checkmark" : "plus"
        button.setImage(UIImage(systemName: imageName), for: .normal)
        
        button.alpha = isCompleted ? 0.3 : 1
    }
}
