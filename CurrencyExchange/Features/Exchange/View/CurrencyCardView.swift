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
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = false
        return label
    }()

    private let currencyLabel: UILabel = {
        let label = UILabel()

        label.font = UIFontMetrics(forTextStyle: .subheadline)
            .scaledFont(
                for: .systemFont(ofSize: 12, weight: .medium)
            )

        label.adjustsFontForContentSizeCategory = true
        label.isAccessibilityElement = false

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

        textField.font = UIFontMetrics(forTextStyle: .body)
            .scaledFont(
                for: .systemFont(ofSize: 16, weight: .semibold)
            )

        textField.adjustsFontForContentSizeCategory = true
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad

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
        updateAccessibility(currencyCode: currency)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(currency: Currency, amount: String) {
        flagLabel.text = currency.flag
        currencyLabel.text = currency.code

        if amountTextField.text != amount {
            amountTextField.text = amount
        }
        updateAccessibility(currencyCode: currency.code)
    }

    private func configureUI() {
        backgroundColor = .white
        layer.cornerRadius = 13
        clipsToBounds = true

        currencyStack.addArrangedSubview(flagLabel)
        currencyStack.addArrangedSubview(currencyLabel)
        currencyStack.addArrangedSubview(chevronImageView)

        currencyStack.isUserInteractionEnabled = false

        currencyButton.addSubview(currencyStack)

        addSubview(currencyButton)
        addSubview(amountTextField)

        currencyButton.addTarget(self, action: #selector(currencyButtonTapped), for: .touchUpInside)
        currencyStack.isAccessibilityElement = false
        flagLabel.isAccessibilityElement = false
        currencyLabel.isAccessibilityElement = false
        chevronImageView.isAccessibilityElement = false

        currencyButton.isAccessibilityElement = true
        currencyButton.accessibilityTraits = .button

        amountTextField.isAccessibilityElement = true
    }

    private func setupConstraints() {
        currencyButton.translatesAutoresizingMaskIntoConstraints = false
        currencyStack.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // MARK: - Currency Button
            
            currencyButton.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 8
            ),

            currencyButton.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -8
            ),
            
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

            currencyStack.topAnchor.constraint(
                greaterThanOrEqualTo: currencyButton.topAnchor,
                constant: 4
            ),

            currencyStack.bottomAnchor.constraint(
                lessThanOrEqualTo: currencyButton.bottomAnchor,
                constant: -4
            ),
            
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
            
            amountTextField.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor,
                constant: 8
            ),

            amountTextField.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor,
                constant: -8
            ),
            
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
    
    private func updateAccessibility(currencyCode: String) {
        let selectCurrencyFormat = NSLocalizedString(
            "currency_card.select_currency",
            comment: "VoiceOver label for currency selection"
        )

        currencyButton.accessibilityLabel =
            String.localizedStringWithFormat(
                selectCurrencyFormat,
                currencyCode
            )

        currencyButton.accessibilityHint = NSLocalizedString(
            "currency_card.select_currency_hint",
            comment: "VoiceOver hint for currency selection"
        )

        let amountFormat = NSLocalizedString(
            "currency_card.amount",
            comment: "VoiceOver label for amount field"
        )

        amountTextField.accessibilityLabel =
            String.localizedStringWithFormat(
                amountFormat,
                currencyCode
            )

        let hintKey = amountTextField.isEnabled
            ? "currency_card.amount_editable_hint"
            : "currency_card.amount_read_only_hint"

        amountTextField.accessibilityHint = NSLocalizedString(
            hintKey,
            comment: "VoiceOver hint for amount field"
        )
    }
    
    @objc private func currencyButtonTapped() {
        onCurrencyTap?()
    }
}
