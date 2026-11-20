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
    private var rateTask: Task<Void, Never>?

    init(viewModel: ExchangeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .systemGreen
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Exchange calculator"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private let rateLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate not loaded"
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

        configureUI()
        setupConstraints()
        setupActions()
        bindViewModel()

        startRateTask { viewModel in
            await viewModel.loadRate()
        }
    }

    private func renderLoadingState(_ state: ExchangeViewState) {
        let isLoading = state.loadingState == .loading

        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        swapButton.isEnabled = true
        sourceCard.isCurrencySelectionEnabled = true
        targetCard.isCurrencySelectionEnabled = true
    }

    private func renderRateStatus(_ state: ExchangeViewState) {
        statusLabel.text = state.errorMessage ?? state.rateSourceDescription
        statusLabel.isHidden = false
    }

    private func startRateTask(
        _ operation: @escaping @MainActor (ExchangeViewModel) async -> Void
    ) {
        rateTask?.cancel()
        let model = viewModel
        rateTask = Task { [weak self] in
            guard self != nil, !Task.isCancelled else { return }
            await operation(model)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed || navigationController?.isBeingDismissed == true {
            rateTask?.cancel()
            rateTask = nil
        }
    }

    deinit {
        rateTask?.cancel()
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

            self.startRateTask { viewModel in
                await viewModel.selectCurrency(currency, for: field)
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
            self?.render(state: state)
        }

        render(state: viewModel.state)
    }

    private func render(state: ExchangeViewState) {
        rateLabel.text = state.rateDescription

        renderLoadingState(state)
        renderRateStatus(state)

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
                .precision(.fractionLength(4))
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
            loadingIndicator,
            statusLabel,
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
            loadingIndicator.leadingAnchor.constraint(
                equalTo: rateLabel.trailingAnchor,
                constant: 8
            ),
            loadingIndicator.centerYAnchor.constraint(
                equalTo: rateLabel.centerYAnchor
            ),
            statusLabel.topAnchor.constraint(
                equalTo: rateLabel.bottomAnchor,
                constant: 4
            ),
            statusLabel.leadingAnchor.constraint(
                equalTo: rateLabel.leadingAnchor
            ),
            statusLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -16
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
                equalTo: statusLabel.bottomAnchor,
                constant: 16
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

        sourceCard.amountTextField.delegate = self
        targetCard.amountTextField.delegate = self

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

        targetCard.amountTextField.addTarget(
            self,
            action: #selector(targetEditingBegan),
            for: .editingDidBegin
        )

        sourceCard.amountTextField.addTarget(
            self,
            action: #selector(sourceEditingBegan),
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
        startRateTask { viewModel in
            await viewModel.swapCurrencies()
        }
    }
}

extension ExchangeViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        guard let currentText = textField.text,
              let swiftRange = Range(range, in: currentText)
                else { return false }

        let newText = currentText.replacingCharacters(in: swiftRange, with: string)

        return AmountInputValidator.isValid(newText)
    }
}
