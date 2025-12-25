//
//  BiometricAuthOverlay.swift
//  CoinX
//

import UIKit
import DefXBiometric

class BiometricAuthOverlay: UIViewController {
    
    enum State {
        case idle
        case authenticating
        case success
        case failure(BiometricError)
        case cancelled
    }
    
    // Background
    private let backgroundLabel = UILabel()
    
    // Bottom card
    private let cardView = UIView()
    private let segmentedControl = UISegmentedControl(items: ["Face ID", "Touch ID"])
    private let appIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    // State-specific views
    private let statusIconImageView = UIImageView()
    private let statusMessageLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let tryAgainOverlayButton = UIButton(type: .system)
    
    private var currentState: State = .idle
    private var currentAttemptId: UUID?
    private var onDismiss: (() -> Void)?
    private var onCancel: (() -> Void)?
    private var isAuthenticating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(for: .idle)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAuthentication()
    }
    
    private func setupUI() {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        
        backgroundLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundLabel.text = "Authenticating..."
        backgroundLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        backgroundLabel.textColor = .white
        backgroundLabel.textAlignment = .center
        backgroundLabel.numberOfLines = 0
        view.addSubview(backgroundLabel)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: -4)
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOpacity = 0.2
        view.addSubview(cardView)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        cardView.addSubview(segmentedControl)
        
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        appIconImageView.contentMode = .scaleAspectFit
        appIconImageView.layer.cornerRadius = 16
        appIconImageView.clipsToBounds = true
        appIconImageView.image = UIImage(named: "definex-amblem")
        cardView.addSubview(appIconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Biometric Authentication"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        cardView.addSubview(titleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Authenticate to continue"
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        cardView.addSubview(subtitleLabel)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Confirm your identity to continue"
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .tertiaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        cardView.addSubview(descriptionLabel)
        
        statusIconImageView.translatesAutoresizingMaskIntoConstraints = false
        statusIconImageView.contentMode = .scaleAspectFit
        statusIconImageView.isHidden = true
        cardView.addSubview(statusIconImageView)
        
        statusMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        statusMessageLabel.font = .systemFont(ofSize: 15)
        statusMessageLabel.textAlignment = .center
        statusMessageLabel.numberOfLines = 0
        statusMessageLabel.textColor = .label
        statusMessageLabel.isHidden = true
        cardView.addSubview(statusMessageLabel)
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmButton.backgroundColor = .systemGreen
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.isHidden = true
        cardView.addSubview(confirmButton)
        
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Try Again", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 12
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryButton.isHidden = true
        cardView.addSubview(retryButton)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cardView.addSubview(cancelButton)
        
        tryAgainOverlayButton.translatesAutoresizingMaskIntoConstraints = false
        tryAgainOverlayButton.setTitle("Try Again", for: .normal)
        tryAgainOverlayButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        tryAgainOverlayButton.backgroundColor = .systemBlue
        tryAgainOverlayButton.setTitleColor(.white, for: .normal)
        tryAgainOverlayButton.layer.cornerRadius = 12
        tryAgainOverlayButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        tryAgainOverlayButton.addTarget(self, action: #selector(tryAgainOverlayTapped), for: .touchUpInside)
        tryAgainOverlayButton.isHidden = true
        view.addSubview(tryAgainOverlayButton)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backgroundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            backgroundLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            backgroundLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            tryAgainOverlayButton.topAnchor.constraint(equalTo: backgroundLabel.bottomAnchor, constant: 32),
            tryAgainOverlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            segmentedControl.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: 250),
            
            appIconImageView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            appIconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            appIconImageView.widthAnchor.constraint(equalToConstant: 64),
            appIconImageView.heightAnchor.constraint(equalToConstant: 64),
            
            titleLabel.topAnchor.constraint(equalTo: appIconImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            statusIconImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            statusIconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            statusIconImageView.widthAnchor.constraint(equalToConstant: 48),
            statusIconImageView.heightAnchor.constraint(equalToConstant: 48),
            
            statusMessageLabel.topAnchor.constraint(equalTo: statusIconImageView.bottomAnchor, constant: 12),
            statusMessageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            statusMessageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            confirmButton.topAnchor.constraint(equalTo: statusMessageLabel.bottomAnchor, constant: 24),
            confirmButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            
            retryButton.topAnchor.constraint(equalTo: statusMessageLabel.bottomAnchor, constant: 24),
            retryButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            retryButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            retryButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: cardView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // Configure segmented control based on available biometric type
        configureBiometricSegments()
    }
    
    private func configureBiometricSegments() {
        let biometricType = DefXBiometricAuth.shared.availableBiometricType()
        
        switch biometricType {
        case .faceID:
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.setEnabled(false, forSegmentAt: 1)
            segmentedControl.setEnabled(true, forSegmentAt: 0)
        case .touchID:
            segmentedControl.selectedSegmentIndex = 1
            segmentedControl.setEnabled(true, forSegmentAt: 1)
            segmentedControl.setEnabled(false, forSegmentAt: 0)
        case .none:
            segmentedControl.setEnabled(false, forSegmentAt: 0)
            segmentedControl.setEnabled(false, forSegmentAt: 0)
        }
    }
    
    private func updateUI(for state: State) {
        currentState = state
        
        switch state {
        case .idle, .authenticating:
            cardView.isHidden = false
            // Lock interaction during authentication
            cardView.isUserInteractionEnabled = false
            cancelButton.isEnabled = false
            backgroundLabel.isHidden = false
            backgroundLabel.text = "Authenticating..."
            tryAgainOverlayButton.isHidden = true
            statusIconImageView.isHidden = true
            statusMessageLabel.isHidden = true
            confirmButton.isHidden = true
            retryButton.isHidden = true
            cancelButton.isHidden = false
            
        case .success:
            cardView.isHidden = false
            // Unlock interaction after authentication
            cardView.isUserInteractionEnabled = true
            cancelButton.isEnabled = true
            backgroundLabel.isHidden = true
            tryAgainOverlayButton.isHidden = true
            statusIconImageView.isHidden = false
            statusIconImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusIconImageView.tintColor = .systemGreen
            statusMessageLabel.isHidden = false
            statusMessageLabel.text = "Verified, confirm to continue..."
            statusMessageLabel.textColor = .systemGreen
            confirmButton.isHidden = false
            retryButton.isHidden = true
            cancelButton.isHidden = false
            
        case .failure(let error):
            cardView.isHidden = false
            // Unlock interaction after authentication
            cardView.isUserInteractionEnabled = true
            cancelButton.isEnabled = true
            backgroundLabel.isHidden = true
            tryAgainOverlayButton.isHidden = true
            statusIconImageView.isHidden = false
            statusIconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            statusIconImageView.tintColor = .systemRed
            statusMessageLabel.isHidden = false
            statusMessageLabel.text = error.displayMessage
            statusMessageLabel.textColor = .systemRed
            confirmButton.isHidden = true
            retryButton.isHidden = false
            cancelButton.isHidden = false
            
        case .cancelled:
            cardView.isHidden = true
            cardView.isUserInteractionEnabled = false
            cancelButton.isEnabled = false
            backgroundLabel.isHidden = false
            backgroundLabel.text = "To access Portfolio without authentication, update your security settings."
            tryAgainOverlayButton.isHidden = false
            currentAttemptId = nil
        }
    }
    
    private func startAuthentication() {
        // Lock overlay during authentication
        isAuthenticating = true
        updateUI(for: .authenticating)
        
        // Create new attempt ID to track this authentication
        let attemptId = UUID()
        currentAttemptId = attemptId
        
        // Build security policy from user settings
        let policy = buildSecurityPolicy()
        
        DefXBiometricAuth.shared.authenticate(
            reason: "Authenticate to access your portfolio",
            securityPolicy: policy
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Ignore callback if attempt was cancelled or is from a different attempt
                guard self.currentAttemptId == attemptId else {
                    return
                }
                
                // Unlock overlay after authentication completes
                self.isAuthenticating = false
                
                switch result {
                case .success:
                    self.updateUI(for: .success)
                case .failure(let error):
                    self.updateUI(for: .failure(error))
                }
            }
        }
    }
    
    private func buildSecurityPolicy() -> SecurityPolicy {
        let defaults = UserDefaults.standard
        var blockedRisks: Set<SecurityRisk> = []
        
        let blockJailbreak = defaults.object(forKey: "security_block_jailbreak") as? Bool ?? true
        let blockSimulator = defaults.object(forKey: "security_block_simulator") as? Bool ?? true
        let blockHooking = defaults.object(forKey: "security_block_hooking") as? Bool ?? true
        let blockDebugger = defaults.object(forKey: "security_block_debugger") as? Bool ?? false
        
        if blockJailbreak {
            blockedRisks.insert(.jailbreak)
        }
        if blockSimulator {
            blockedRisks.insert(.simulator)
        }
        if blockHooking {
            blockedRisks.insert(.hooking)
        }
        if blockDebugger {
            blockedRisks.insert(.debugger)
        }
        
        return SecurityPolicy(blockedRisks: blockedRisks)
    }
    
    @objc private func confirmButtonTapped() {
        // Prevent action while authenticating
        guard !isAuthenticating else { return }
        // Only dismiss on successful authentication
        dismissOverlay()
    }
    
    @objc private func retryButtonTapped() {
        // Prevent action while authenticating
        guard !isAuthenticating else { return }
        // Retry authentication after failure
        startAuthentication()
    }
    
    @objc private func cancelButtonTapped() {
        guard !isAuthenticating else { return }
        onCancel?()
    }
    
    @objc private func tryAgainOverlayTapped() {
        // Prevent action while authenticating
        guard !isAuthenticating else { return }
        // Return to normal mode and restart authentication
        startAuthentication()
    }
    
    private func dismissOverlay() {
        // Prevent dismissal while authenticating
        guard !isAuthenticating else { return }
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
    
    func setDismissHandler(_ handler: @escaping () -> Void) {
        onDismiss = handler
    }
    
    func setCancelHandler(_ handler: @escaping () -> Void) {
        onCancel = handler
    }
}

