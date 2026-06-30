//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Игорь Глебов on 21.06.2026.
//
import UIKit

final class NewCategoryViewController: UIViewController {
    // MARK: - Public Properties
    var onCategoryCreated: ((String) -> Void)?
    
    // MARK: - Private Properties
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("textField.placeholder", comment: "Text displayed as placeholder")
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = .label
        textField.backgroundColor = Colors.tableBackgroundColor
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("doneButton", comment: "Text displayed on doneButton"), for: .normal)
        button.setTitleColor(Colors.TitleOnblackWhiteButtonsColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.viewBackground
        setupNavBar()
        setupTextField()
        setupButton()
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        title = NSLocalizedString("NewCategoryNavBar.title", comment: "NavBarTitle")
        navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.label
        ]
    }
    
    private func setupTextField() {
        view.addSubview(textField)
        
        textField.delegate = self
        
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func setupButton() {
        view.addSubview(doneButton)
        
        doneButton.addTarget(
            self,
            action: #selector(didTapDoneButton),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateCreateButtonState() {
        let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let canCreate = !title.isEmpty
        
        doneButton.isEnabled = canCreate
        doneButton.backgroundColor = canCreate ? Colors.blackWhiteButtonsColor : .systemGray
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func didTapDoneButton() {
        let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !title.isEmpty else {
            return
        }
        
        onCategoryCreated?(title)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension NewCategoryViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(
            in: stringRange,
            with: string
        )
        
        return updatedText.count <= 38
    }
}
