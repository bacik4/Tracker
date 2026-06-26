//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 31.05.2026.
//
import UIKit

final class CategoryViewController: UIViewController {
    // MARK: - Public Properties
    
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Private Properties
    
    private let viewModel: CategoryViewModel
    private let tableView = UITableView()
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .backgroundStar)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("backLabel.title", comment: "Text displayed when you have no category")
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
    
    private var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("addCategoryButton.title", comment: "Text displayed on the button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let rowHeight = 75
    
    init(selectedCategoryTitle: String? = nil) {
        self.viewModel = CategoryViewModel(selectedCategoryTitle: selectedCategoryTitle)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavBar()
        setupBack()
        setupButton()
        setupTableView()
        bindViewModel()
        viewModel.loadCategories()
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        title = NSLocalizedString("CategoryNavBar.title", comment: "Navigation bar title")
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
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
            backLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupButton() {
        view.addSubview(button)
        
        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.rowHeight = CGFloat(rowHeight)
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            heightConstraint
            
        ])
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.updateState()
        }
        
        viewModel.onCategorySelected = { [weak self] title in
            self?.onCategorySelected?(title)
            self?.dismiss(animated: true)
        }
        
        viewModel.onError = { error in
            print(error)
        }
    }
    
    private func updateState() {
        let isEmpty = viewModel.isEmpty
        
        emptyStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        tableViewHeightConstraint?.constant = CGFloat(viewModel.numberOfRows()) * 75
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func didTapButton() {
        let viewController = NewCategoryViewController()
        
        viewController.onCategoryCreated = { [weak self] title in
            self?.viewModel.addCategory(title)
            
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
        cell.configure(with: cellViewModel)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
    }
}
