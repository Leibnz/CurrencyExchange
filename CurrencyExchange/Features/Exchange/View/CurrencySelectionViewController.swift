//
//  CurrencySelectionViewController.swift
//  CurrencyExchange
//
//  Created by Andrew on 05.11.2026.
//

import UIKit

final class CurrencySelectionViewController: UIViewController {

    var onCurrencySelected: ((Currency) -> Void)?

    private let currencies: [Currency]
    private let selectedCurrency: Currency

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose currency"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            UIImage(systemName: "xmark"),
            for: .normal
        )
        button.tintColor = .darkGray
        return button
    }()

    private let tableView: UITableView = {
        let table = UITableView(
            frame: .zero,
            style: .plain
        )

        table.backgroundColor = .white
        table.separatorStyle = .none
        table.layer.cornerRadius = 14
        table.clipsToBounds = true
        table.rowHeight = 40
        table.isScrollEnabled = false

        return table
    }()

    init(
        currencies: [Currency],
        selectedCurrency: Currency
    ) {
        self.currencies = currencies
        self.selectedCurrency = selectedCurrency

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(
            red: 0.965,
            green: 0.965,
            blue: 0.965,
            alpha: 1
        )

        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(tableView)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            CurrencySelectionCell.self,
            forCellReuseIdentifier: CurrencySelectionCell.reuseIdentifier
        )
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            closeButton.centerYAnchor.constraint(
                equalTo: titleLabel.centerYAnchor
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            tableView.topAnchor.constraint(
                equalTo: closeButton.bottomAnchor,
                constant: 8
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 12
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -12
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: CGFloat(currencies.count) * 40
            )
        ])
    }

    private func setupActions() {
        closeButton.addTarget(
            self,
            action: #selector(closeTapped),
            for: .touchUpInside
        )
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension CurrencySelectionViewController:
    UITableViewDelegate,
    UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        currencies.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: CurrencySelectionCell.reuseIdentifier,
            for: indexPath
        )

        guard let cell = cell as? CurrencySelectionCell else {
            return cell
        }

        let currency = currencies[indexPath.row]

        cell.configure(
            currency: currency,
            isSelected: currency == selectedCurrency
        )

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let currency = currencies[indexPath.row]

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        dismiss(animated: true) { [weak self] in
            self?.onCurrencySelected?(currency)
        }
    }
}
