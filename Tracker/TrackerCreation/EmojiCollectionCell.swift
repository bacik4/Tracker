//
//  EmojiCollectionCell.swift
//  Tracker
//
//  Created by Игорь Глебов on 01.06.2026.
//
import UIKit

final class EmojiCollectionCell: UICollectionViewCell {
    // MARK: - Private Properties
    
    private let label = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
    }
    
    private func setupLayout() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    // MARK: - Configuration
    
    func configure(with emoji: String, isSelected: Bool) {
        label.text = emoji
        contentView.backgroundColor = isSelected ? .systemGray5 : .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        contentView.backgroundColor = .clear
    }
}
