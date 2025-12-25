//
//  SecuritySettingsViewController.swift
//  CoinX
//

import UIKit

class SecuritySettingsViewController: UIViewController, SecuritySettings.View {
    
    var presenter: SecuritySettings.Presenter!
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var currentState = SecuritySettingsState(
        isBiometricEnabled: true,
        blockOnJailbreak: true,
        blockOnSimulator: true,
        blockOnHooking: true,
        blockOnDebugger: false
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.notifyViewLoaded()
    }
    
    func updateSettings(_ settings: SecuritySettingsState) {
        currentState = settings
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Security Settings"
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SecuritySettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return currentState.isBiometricEnabled ? 4 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.configure(
                title: "Biometric Authentication",
                subtitle: "Use biometrics to access your portfolio",
                isOn: currentState.isBiometricEnabled
            ) { [weak self] isOn in
                self?.presenter.toggleBiometric(isOn)
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            let titles = [
                "Block Rooted Devices",
                "Block Emulators",
                "Block Hooked Devices",
                "Block Debuggable Apps"
            ]
            let subtitles = [
                "Prevent authentication on rooted devices",
                "Prevent authentication on emulators",
                "Prevent authentication when hooking frameworks detected",
                "Prevent authentication in debug mode"
            ]
            let values = [
                currentState.blockOnJailbreak,
                currentState.blockOnSimulator,
                currentState.blockOnHooking,
                currentState.blockOnDebugger
            ]
            
            cell.configure(
                title: titles[indexPath.row],
                subtitle: subtitles[indexPath.row],
                isOn: values[indexPath.row]
            ) { [weak self] isOn in
                switch indexPath.row {
                case 0:
                    self?.presenter.toggleBlockOnJailbreak(isOn)
                case 1:
                    self?.presenter.toggleBlockOnSimulator(isOn)
                case 2:
                    self?.presenter.toggleBlockOnHooking(isOn)
                case 3:
                    self?.presenter.toggleBlockOnDebugger(isOn)
                default:
                    break
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Biometric Authentication"
        } else if section == 1 {
            return currentState.isBiometricEnabled ? "Security Policies" : nil
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 && currentState.isBiometricEnabled {
            return "Configure security restrictions for biometric authentication"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private class SwitchCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelsStackView = UIStackView()
    private let switchControl = UISwitch()
    private var onToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.numberOfLines = 0
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 2
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        
        contentView.addSubview(labelsStackView)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            labelsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11),
            labelsStackView.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -12),
            
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, subtitle: String, isOn: Bool, onToggle: @escaping (Bool) -> Void) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        switchControl.isOn = isOn
        self.onToggle = onToggle
    }
    
    @objc private func switchToggled() {
        onToggle?(switchControl.isOn)
    }
}

