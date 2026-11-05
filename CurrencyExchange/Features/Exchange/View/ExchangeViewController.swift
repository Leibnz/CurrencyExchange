//
//  ExchangeViewController.swift
//  CurrencyExchange
//
//  Created by Andrew on 14.10.2026.
//

import UIKit

final class ExchangeViewController: UIViewController {
    
    private let viewModel: ExchangeViewModel
    private var previousCurrencies: (from: Currency, to: Currency)?
    
    init(viewModel: ExchangeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        isEditable: true
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
        
        Task {
            await viewModel.loadRate()
        }
        
        configureUI()
        setupConstraints()
        setupActions()
        bindViewModel()
    }
    
    private func presentCurrencySelection(for field: CurrencySelectionField) {
        let selectedCurrency: Currency

        switch field {
        case .source:
            selectedCurrency = viewModel.state.selectedFromCurrency

        case .target:
            selectedCurrency = viewModel.state.selectedToCurrency
        }

        let controller = CurrencySelectionViewController(
            currencies: Currency.supported,
            selectedCurrency: selectedCurrency
        )

        controller.onCurrencySelected = { [weak self] currency in
            guard let self else { return }

            Task {
                await self.viewModel.selectCurrency(
                    currency,
                    for: field
                )
            }
        }

        controller.modalPresentationStyle = .pageSheet

        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 20
        }

        present(controller, animated: true)
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.render(state: state)
            }
        }
        
        render(state: viewModel.state)
    }
    
    private func render(state: ExchangeViewState, forceUpdate: Bool = false) {
        rateLabel.text = state.rateDescription
        
        let currenciesChanged: Bool
        
        if let previousCurrencies {
            currenciesChanged =
                previousCurrencies.from != state.selectedFromCurrency ||
                previousCurrencies.to != state.selectedToCurrency
        } else {
            currenciesChanged = true
        }
        
        previousCurrencies = (
            from: state.selectedFromCurrency,
            to: state.selectedToCurrency
        )
        
        let sourceAmount = format(state.inputAmount)
        let targetAmount = format(state.convertedAmount)
        
        let shouldUpdateSource = currenciesChanged || !sourceCard.amountTextField.isFirstResponder
        let shouldUpdateTarget = currenciesChanged || !targetCard.amountTextField.isFirstResponder
        
        sourceCard.configure(
            currency: state.selectedFromCurrency,
            amount: shouldUpdateSource ? sourceAmount : sourceCard.amountTextField.text ?? ""
        )
        
        targetCard.configure(
            currency: state.selectedToCurrency,
            amount: shouldUpdateTarget ? targetAmount : targetCard.amountTextField.text ?? ""
        )
    }
    
    private func format(_ amount: Decimal) -> String {
        amount.formatted(
            .number
                .grouping(.automatic)
                .precision(.fractionLength(2))
        )
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
            action: #selector(sourceAmountChanged),
            for: .editingChanged
        )
        
        targetCard.amountTextField.addTarget(
            self,
            action: #selector(targetAmountChanged),
            for: .editingChanged
        )
        
        sourceCard.amountTextField.addTarget(
            self,
            action: #selector(targetEditingBegan),
            for: .editingDidBegin
        )
        
        swapButton.addTarget(
            self,
            action: #selector(swapCurrencies),
            for: .touchUpInside
        )
        
        sourceCard.onCurrencyTap = { [weak self] in
            self?.presentCurrencySelection(for: .source)
        }
        
        targetCard.onCurrencyTap = { [weak self] in
            self?.presentCurrencySelection(for: .target)
        }
    }
    
    @objc private func sourceEditingBegan() {
        viewModel.setActiveField(.source)
    }
    
    @objc private func targetEditingBegan() {
        viewModel.setActiveField(.target)
    }
    
    @objc private func sourceAmountChanged() {
        viewModel.updateAmount(
            sourceCard.amountTextField.text ?? "",
            from: .source
        )
    }
    
    @objc private func targetAmountChanged() {
        viewModel.updateAmount(
            targetCard.amountTextField.text ?? "",
            from: .target
        )
    }
    
    @objc private func swapCurrencies() {
        Task {
            await viewModel.swapCurrencies()
        }
    }
}

