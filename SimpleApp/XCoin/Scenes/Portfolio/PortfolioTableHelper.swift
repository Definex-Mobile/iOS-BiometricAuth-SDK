//
//  PortfolioTableHelper.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import UIKit

protocol PortfolioTableHelperDelegate: AnyObject {
    func observationListener(type: PortfolioTableHelper.UserInteraction)
}

class PortfolioTableHelper: NSObject {
    
    // MARK: - Properties
    private weak var tableView: UITableView?
    
    weak var presenter: Portfolio.Presenter?
    weak var delegate: PortfolioTableHelperDelegate?
    
    var items: [Portfolio.ListItem] = [] {
        didSet {
            // Reload the table view when the state changes.
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    // MARK: - Initialization
    required init(_ tableView: UITableView) {
        super.init()
        
        // Configure the provided table view's properties and delegates.
        self.tableView = tableView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        // Register cell nibs for reuse.
        tableView.register(.init(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(.init(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        tableView.register(.init(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "CoinCell")
        tableView.register(.init(nibName: "PortfolioCell", bundle: nil), forCellReuseIdentifier: "PortfolioCell")
        tableView.register(.init(nibName: "DepositCell", bundle: nil), forCellReuseIdentifier: "DepositCell")
    }
}

// MARK: - Public Functions
extension PortfolioTableHelper {
    
    // Updates the state of the table view.
    func update(with items: [Portfolio.ListItem]) {
        self.items = items
    }
}

// MARK: - UITableViewDataSource
extension PortfolioTableHelper: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch items[indexPath.row] {
        case .emptyRow(let height):
            let cell: EmptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
            cell.configure(with: height)
            return cell
        case .portfolio:
            let cell: PortfolioCell = tableView.dequeueReusableCell(withIdentifier: "PortfolioCell") as! PortfolioCell
            return cell
        case .depositWithdraw:
            let cell: DepositCell = tableView.dequeueReusableCell(withIdentifier: "DepositCell") as! DepositCell
            cell.setupCell(delegate: self)
            return cell
        case .title(let text):
            let cell: TitleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as! TitleCell
            cell.configure(text: text)
            return cell
        case .coin(let item):
            let cell: CoinCell = tableView.dequeueReusableCell(withIdentifier: "CoinCell") as! CoinCell
            cell.configure(with: item)
            return cell
        }
    }
}

extension PortfolioTableHelper: DepositCellDelegate {
    func depositButtonTapped() {
        delegate?.observationListener(type: .depositButtonTapped)
    }
    
    func withdrawButtonTapped() {
        delegate?.observationListener(type: .withdrawButtonTapped)
    }
}

extension PortfolioTableHelper {
    enum UserInteraction {
        case depositButtonTapped
        case withdrawButtonTapped
    }
}

private extension CoinCell {
    
    func configure(with model: Portfolio.ListRowItem) {
        coinLongnameLabel.text = model.longName
        coinShortNameLabel.text = model.shortName
        coinPriceLabel.text = model.value
        percentageLabel.text = model.changePercentage
        percentageLabel.textColor = model.isChangePositive ? UIColor.init(named: "XGreen") : UIColor.init(named: "XRed")
        coinImageView.sd_setImage(with: URL.init(string: model.imageUrl))
    }
}
