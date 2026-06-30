import UIKit

final class StatisticCardView: UIView {
    
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(value: String, title: String) {
        super.init(frame: .zero)
        setupView()
        configure(value: value, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientBorder()
    }
    
    private func setupView() {
        backgroundColor = Colors.viewBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        addSubview(stackView)

        valueLabel.font = .systemFont(ofSize: 34, weight: .bold)
        valueLabel.textColor = .label

        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .label

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupGradientBorder() {
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.27, green: 0.9, blue: 0.62, alpha: 1).cgColor,
            UIColor(red: 1.0, green: 0.45, blue: 0.29, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 16
        ).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shape
        
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func configure(value: String, title: String) {
        valueLabel.text = value
        titleLabel.text = title
    }
}
