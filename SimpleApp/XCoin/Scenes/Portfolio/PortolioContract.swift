//
//  PortolioContract.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 14.09.2023.
//

import Foundation

protocol PortfolioViewProtocol: BaseView {
    var presenter: Portfolio.Presenter! { get set }
    
    func updateTableView(with state: [Portfolio.ListItem])
}

protocol PortfolioInteractorProtocol: AnyObject {
    var presenter: Portfolio.Presenter? { get set }
    
    var coins: [PortfolioCoin] { get }
    
    func fetchCoins()
}

protocol PortfolioPresenterProtocol: BasePresenter {
    var view: Portfolio.View? { get set }
    var interactor: Portfolio.Interactor! { get set }
    var router: Portfolio.Router! { get set }
    
    // MARK: Interactor related methods
    func didFetchCoins()
}

protocol PortfolioRouterProtocol: BaseRouter {
    var presenter: Portfolio.Presenter? { get set }
    
    func navigateToCoinDetail(with coin: String)
}

struct Portfolio {
    typealias View = PortfolioViewProtocol
    typealias Interactor = PortfolioInteractorProtocol
    typealias Presenter = PortfolioPresenterProtocol
    typealias Router = PortfolioRouterProtocol
}

extension Portfolio {
    
    enum ListItem {
        case emptyRow(_ height: CGFloat)
        case portfolio
        case depositWithdraw
        case title(text: String)
        case coin(_ item: ListRowItem)
    }
    
    struct ListRowItem {
        var longName: String
        var shortName: String
        var imageUrl: String
        var value: String
        var changePercentage: String
        var isChangePositive: Bool
        var onItemClicked: ((ListRowItem) -> ())?
    }
}


extension Portfolio.Presenter {
    var _view: BaseView? { view }
}
