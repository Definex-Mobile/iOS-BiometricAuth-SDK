//
//  HomeViewController.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import UIKit

class HomeViewController: UIViewController, Home.View {
    
    @IBOutlet private(set) weak var tableView: UITableView!
    
    var presenter: Home.Presenter!
    
    private var tableHelper: HomeTableHelper!
    private var hasLoadedData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasLoadedData {
            hasLoadedData = true
            presenter.notifyViewLoaded()
        }
    }
    
    func updateTableView(with state: [Home.ListItem]) {
        tableHelper.update(with: state)
    }
}


private extension HomeViewController {
    
    private func setupUI() {
        tableHelper = .init(tableView)
        
    }
}
