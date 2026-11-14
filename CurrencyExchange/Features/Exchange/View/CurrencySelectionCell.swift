//
//  CurrencySelectionCell.swift
//  CurrencyExchange
//
//  Created by Andrew on 05.11.2026.
//

import UIKit

final class CurrencySelectionCell: UITableViewCell {

    static let reuseIdentifier = "CurrencySelectionCell"

    private let flagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray4
        return imageView
    }()

    private let currencyStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        return stack
    }()

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none

        currencyStack.addArrangedSubview(flagLabel)
        currencyStack.addArrangedSubview(currencyLabel)

        contentView.addSubview(currencyStack)
        contentView.addSubview(selectionImageView)
    }

    private func setupConstraints() {
        flagLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyStack.translatesAutoresizingMaskIntoConstraints = false
        selectionImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            flagLabel.widthAnchor.constraint(equalToConstant: 24),
            flagLabel.heightAnchor.constraint(equalToConstant: 24),

            currencyStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            currencyStack.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),

            selectionImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            selectionImageView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),
            selectionImageView.widthAnchor.constraint(equalToConstant: 18),
            selectionImageView.heightAnchor.constraint(equalToConstant: 18),

            currencyStack.trailingAnchor.constraint(
                lessThanOrEqualTo: selectionImageView.leadingAnchor,
                constant: -8
            )
        ])
    }

    func configure(
        currency: Currency,
        isSelected: Bool
    ) {
        flagLabel.text = currency.flag
        currencyLabel.text = currency.code

        let imageName = isSelected
            ? "checkmark.circle.fill"
            : "circle"

        selectionImageView.image = UIImage(
            systemName: imageName
        )

        selectionImageView.tintColor = isSelected
            ? .systemGreen
            : .systemGray4
    }
}
