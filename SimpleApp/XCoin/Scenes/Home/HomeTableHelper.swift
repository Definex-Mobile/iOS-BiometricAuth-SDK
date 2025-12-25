//
//  HomeTableHelper.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import UIKit

class HomeTableHelper: NSObject {
    
    // MARK: - Properties
    private weak var tableView: UITableView?
    
    weak var presenter: Home.Presenter?
    
    var items: [Home.ListItem] = [] {
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
        tableView.register(.init(nibName: "HomeInvestCell", bundle: nil), forCellReuseIdentifier: "HomeInvestCell")
        tableView.register(.init(nibName: "TitleCell", bundle: nil), forCellReuseIdentifier: "TitleCell")
        tableView.register(.init(nibName: "EmptyCell", bundle: nil), forCellReuseIdentifier: "EmptyCell")
        tableView.register(.init(nibName: "CoinCell", bundle: nil), forCellReuseIdentifier: "CoinCell")
    }
}

// MARK: - Public Functions
extension HomeTableHelper {
    
    // Updates the state of the table view.
    func update(with items: [Home.ListItem]) {
        self.items = items
    }
}

// MARK: - UITableViewDataSource
extension HomeTableHelper: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch items[indexPath.row] {
        case .emptyRow(let height):
            let theCell: EmptyCell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell") as! EmptyCell
            theCell.configure(with: height)
            cell = theCell
        case .invest:
            let theCell: HomeInvestCell = tableView.dequeueReusableCell(withIdentifier: "HomeInvestCell") as! HomeInvestCell
            cell = theCell
        case .title(let text):
            let theCell: TitleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell") as! TitleCell
            theCell.configure(text: text)
            cell = theCell
        case .coin(let item):
            let theCell: CoinCell = tableView.dequeueReusableCell(withIdentifier: "CoinCell") as! CoinCell
            theCell.configure(with: item)
            cell = theCell
        }
        
        return cell
    }
}

private extension CoinCell {
    
    func configure(with model: Home.ListRowItem) {
        coinLongnameLabel.text = model.longName
        coinShortNameLabel.text = model.shortName
        coinPriceLabel.text = model.value
        percentageLabel.text = model.changePercentage
        percentageLabel.textColor = model.isChangePositive ? UIColor.init(named: "XGreen") : UIColor.init(named: "XRed")
        coinImageView.sd_setImage(with: URL.init(string: model.imageUrl))
    }
}
