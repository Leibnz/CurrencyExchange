//
//  CurrencyCardView.swift
//  CurrencyExchange
//
//  Created by Andrew on 16.10.2026.
//

import UIKit

final class CurrencyCardView: UIView {
    
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
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let amountTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 12, weight: .semibold)
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        textField.borderStyle = .none
        textField.adjustsFontForContentSizeCategory = true
        textField.minimumFontSize = 10
        return textField
    }()
    
    private let currencyStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        return stackView
    }()
    
    init(flag: String, currency: String, isEditable: Bool) {
        super.init(frame: .zero)
        
        flagLabel.text = flag
        currencyLabel.text = currency
        amountTextField.isEnabled = isEditable
        chevronImageView.isHidden = isEditable
        
        configureUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 13
        self.clipsToBounds = true
        
        currencyStack.addArrangedSubview(flagLabel)
        currencyStack.addArrangedSubview(currencyLabel)
        currencyStack.addArrangedSubview(chevronImageView)
        
        self.addSubview(currencyStack)
        self.addSubview(amountTextField)
    }

    private func setupConstraints() {
        currencyStack.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currencyStack.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 12
            ),
            currencyStack.centerYAnchor.constraint(
                equalTo: self.centerYAnchor
            ),
            
            amountTextField.leadingAnchor.constraint(
                greaterThanOrEqualTo: currencyStack.trailingAnchor,
                constant: 8
            ),
            amountTextField.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -12
            ),
            amountTextField.centerYAnchor.constraint(
                equalTo: self.centerYAnchor
            ),
            amountTextField.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 75
            )
        ])
    }
}
