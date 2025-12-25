//
//  PortfolioViewController.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit
import DefXBiometric

class PortfolioViewController: UIViewController, Portfolio.View {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var tableHelper: PortfolioTableHelper!
    
    var presenter: Portfolio.Presenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enforceSecurityAndBiometric()
        setupUI()
        presenter.notifyViewLoaded()
        tableHelper.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enforceSecurityAndBiometric()
    }
    
    func updateTableView(with state: [Portfolio.ListItem]) {
        tableHelper.update(with: state)
    }
    
    private func enforceSecurityAndBiometric() {
        // Check if biometric is enabled in settings
        let isBiometricEnabled = UserDefaults.standard.object(forKey: "biometric_enabled") as? Bool ?? true
        guard isBiometricEnabled else { return }        
        showBiometricOverlay()
    }
    
    private func showBiometricOverlay() {
        let overlay = BiometricAuthOverlay()
        overlay.modalPresentationStyle = .overFullScreen
        overlay.modalTransitionStyle = .crossDissolve
        overlay.setCancelHandler { [weak self] in
            self?.tabBarController?.selectedIndex = 2
            overlay.dismiss(animated: true)
        }
        present(overlay, animated: true)
    }
    
    private func showBiometricErrorAlert(_ error: BiometricError) {
        let alert = UIAlertController(
            title: error.displayTitle,
            message: error.displayMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 0
        })
        present(alert, animated: true)
    }
}

private extension PortfolioViewController {
    
    func setupUI() {
        tableHelper = .init(tableView)
    }
}

extension PortfolioViewController: PortfolioTableHelperDelegate {
    func observationListener(type: PortfolioTableHelper.UserInteraction) {
        switch type {
        case .depositButtonTapped:
            let vc = PortfolioDepositDetailVC()
            present(vc, animated: true)
        case .withdrawButtonTapped:
            let vc = PortfolioWithdrawDetailVC()
            present(vc, animated: true)
        }
    }
}
