//
//  HomeContract.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import Foundation

protocol HomeViewProtocol: BaseView {
    var presenter: Home.Presenter! { get set }
    
    func updateTableView(with state: [Home.ListItem])
}

protocol HomeInteractorProtocol: AnyObject {
    var presenter: Home.Presenter? { get set }
    
    var markets: [TrendingCoin] { get }
    
    func fetchMarkets()
}

protocol HomePresenterProtocol: BasePresenter {
    var view: Home.View? { get set }
    var interactor: Home.Interactor! { get set }
    var router: Home.Router! { get set }
    
    // MARK: Interactor related methods
    func didFetchMarkets()
}

protocol HomeRouterProtocol: BaseRouter {
    var presenter: Home.Presenter? { get set }
    
    func navigateToMarketDetail(with marketCode: String)
}

struct Home {
    typealias View = HomeViewProtocol
    typealias Interactor = HomeInteractorProtocol
    typealias Presenter = HomePresenterProtocol
    typealias Router = HomeRouterProtocol
}

extension Home {
    
    enum ListItem {
        case emptyRow(_ height: CGFloat)
        case invest
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


extension Home.Presenter {
    var _view: BaseView? { view }
}
