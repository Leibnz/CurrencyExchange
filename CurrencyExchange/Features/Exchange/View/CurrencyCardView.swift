//
//  CurrencyCardView.swift
//  CurrencyExchange
//
//  Created by Andrew on 16.10.2026.
//

import UIKit

final class CurrencyCardView: UIView {
    
    var onCurrencyTap: (() -> Void)?
    
    var isCurrencySelectionEnabled: Bool {
        get {
            currencyButton.isEnabled
        }
        set {
            currencyButton.isEnabled = newValue
            currencyButton.alpha = newValue ? 1 : 0.5
        }
    }
    
    private let flagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 16, weight: .semibold)
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        textField.isEnabled = true
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    private let currencyStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        return stackView
    }()
    
    private let currencyButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityLabel = "Select currency"
        return button
    }()
    
    init(flag: String, currency: String, isEditable: Bool) {
        super.init(frame: .zero)
        
        flagLabel.text = flag
        currencyLabel.text = currency
        amountTextField.isEnabled = isEditable
        
        configureUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(currency: Currency, amount: String) {
        flagLabel.text = currency.flag
        currencyLabel.text = currency.code
        
        if amountTextField.text != amount {
            amountTextField.text = amount
        }
    }
    
    private func configureUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 13
        self.clipsToBounds = true
        
        currencyStack.addArrangedSubview(flagLabel)
        currencyStack.addArrangedSubview(currencyLabel)
        currencyStack.addArrangedSubview(chevronImageView)
        
        currencyStack.isUserInteractionEnabled = false
        
        currencyButton.addSubview(currencyStack)
        
        self.addSubview(currencyButton)
        self.addSubview(amountTextField)
        
        currencyButton.addTarget(self, action: #selector(currencyButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        currencyButton.translatesAutoresizingMaskIntoConstraints = false
        currencyStack.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // MARK: - Currency Button

            currencyButton.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 12
            ),

            currencyButton.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),

            currencyButton.heightAnchor.constraint(
                greaterThanOrEqualToConstant: 44
            ),

            // MARK: - Currency Stack

            currencyStack.leadingAnchor.constraint(
                equalTo: currencyButton.leadingAnchor,
                constant: 8
            ),

            currencyStack.trailingAnchor.constraint(
                equalTo: currencyButton.trailingAnchor,
                constant: -8
            ),

            currencyStack.centerYAnchor.constraint(
                equalTo: currencyButton.centerYAnchor
            ),

            // MARK: - Amount TextField

            amountTextField.leadingAnchor.constraint(
                greaterThanOrEqualTo: currencyButton.trailingAnchor,
                constant: 8
            ),

            amountTextField.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -12
            ),

            amountTextField.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),

            amountTextField.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 75
            )
        ])
    }
    
    @objc private func currencyButtonTapped() {
        onCurrencyTap?()
    }
}
