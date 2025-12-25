//
//  XHorizontalMenuView.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 18.09.2023.
//

import UIKit

final class XHorizontalMenuView: UIView {
    
    typealias Row = Int
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = .init(width: 100, height: 10)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(XHorizontalMenuCell.self, forCellWithReuseIdentifier: XHorizontalMenuCell.reuseIdentifier())
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 0)
        return collectionView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "XBorderColor")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var menuItems: [String] = []
    
    private var selectedRow: IndexPath = IndexPath(row: 0, section: 0)
    
    var onMenuSelected: ((Row) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareDesign()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        prepareDesign()
    }
    
    // MARK: - Public Functions
    func setItems(_ items: [String]) {
        self.menuItems = items
        collectionView.reloadData()
    }
    
    func setInitialSelectedRow(row: Int) {
        self.selectedRow = .init(row: row, section: 0)
        collectionView.reloadData()
    }
}

extension XHorizontalMenuView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: XHorizontalMenuCell.reuseIdentifier(), for: indexPath) as! XHorizontalMenuCell
        if selectedRow.row == indexPath.row {
            cell.makeThisCellSelected()
        } else {
            cell.makeThisCellUnSelected()
        }
        cell.configure(with: menuItems[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath
        collectionView.reloadData()
        onMenuSelected?(indexPath.row)
    }
}

private extension XHorizontalMenuView {
    
    func prepareDesign() {
        addSubview(containerView)
        containerView.fillSuperview()
        
        containerView.addSubview(collectionView)
        collectionView.fillSuperview()
        
        containerView.addSubview(seperatorView)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 25),
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            seperatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            seperatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            seperatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

final class XHorizontalMenuCell: BaseCollectionViewCell {
    
    private lazy var titleLabel: XMedium14Label = {
        let label = XMedium14Label()
        label.textColor = UIColor.init(named: "XGray")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Primary")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.layer.cornerRadius = 2
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareDesign()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Functions
    func configure(with name: String) {
        titleLabel.text = name
    }
    
    func makeThisCellSelected() {
        titleLabel.textColor = UIColor(named: "Primary")
        selectedView.isHidden = false
    }
    
    func makeThisCellUnSelected() {
        titleLabel.textColor = UIColor(named: "XGray")
        selectedView.isHidden = true
    }
}

private extension XHorizontalMenuCell {
    
    func prepareDesign() {
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(selectedView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: selectedView.topAnchor, constant: -4),
            selectedView.heightAnchor.constraint(equalToConstant: 3),
            selectedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            selectedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            selectedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
    }
}
