//
//  ExchangeViewController.swift
//  CurrencyExchange
//
//  Created by Andrew on 14.10.2026.
//

import UIKit

final class ExchangeViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Exchange calculator"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    private let rateLabel: UILabel = {
        let label = UILabel()
        label.text = "1 USD = 18.042053"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGreen
        return label
    }()
    
    private let sourceCard = CurrencyCardView(
        flag: "🇺🇸",
        currency: "USDc",
        isEditable: true
    )
    
    private let targetCard = CurrencyCardView(
        flag: "🇲🇽",
        currency: "MXN",
        isEditable: false
    )
    
    private let swapButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 13
        button.setImage(
            UIImage(systemName: "arrow.down"),
            for: .normal
        )
        button.layer.borderWidth = 2
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupConstraints()
        setupActions()
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor(
            red: 0.97,
            green: 0.97,
            blue: 0.97,
            alpha: 1
        )
        
        swapButton.layer.borderColor = view.backgroundColor?.cgColor
        
        [
            titleLabel,
            rateLabel,
            sourceCard,
            targetCard,
            swapButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        sourceCard.amountTextField.text = "$9.999"
        targetCard.amountTextField.text = "$184,065"
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 100
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            rateLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 8
            ),
            rateLabel.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            
            sourceCard.topAnchor.constraint(
                equalTo: rateLabel.bottomAnchor,
                constant: 24
            ),
            sourceCard.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            sourceCard.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            sourceCard.heightAnchor.constraint(equalToConstant: 66),
            
            targetCard.topAnchor.constraint(
                equalTo: sourceCard.bottomAnchor,
                constant: 16
            ),
            targetCard.leadingAnchor.constraint(
                equalTo: sourceCard.leadingAnchor
            ),
            targetCard.trailingAnchor.constraint(
                equalTo: sourceCard.trailingAnchor
            ),
            targetCard.heightAnchor.constraint(equalToConstant: 66),
            
            swapButton.centerXAnchor.constraint(
                equalTo: sourceCard.centerXAnchor
            ),
            swapButton.centerYAnchor.constraint(
                equalTo: sourceCard.bottomAnchor,
                constant: 8
            ),
            swapButton.widthAnchor.constraint(equalToConstant: 24),
            swapButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupActions() {
        sourceCard.amountTextField.addTarget(
            self,
            action: #selector(amountChanged),
            for: .editingChanged
        )
        
        swapButton.addTarget(
            self,
            action: #selector(swapCurrencies),
            for: .touchUpInside
        )
    }
    
    @objc private func amountChanged() {
        
    }
    
    @objc private func swapCurrencies() {
        
    }
}

