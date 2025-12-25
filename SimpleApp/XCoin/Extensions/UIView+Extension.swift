//
//  UIView+Extension.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import UIKit

private let loadingContainerTag = 999

// MARK: - Creating Layout
extension UIView {
    
    func addSubviewForAutoLayout(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
    
    func fillSuperview() {
        guard let superview = self.superview else { return }
        self.frame = superview.bounds
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func fillSuperviewWithConstraints() -> [NSLayoutConstraint] {
        guard let superview = self.superview else { return [] }
        translatesAutoresizingMaskIntoConstraints = false
        return [
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ]
    }
    
    /// Returns view with tag in subviews. Not recursive as built in view(with tag:) method
    ///
    /// - Parameter tag: Tag of the searched subview
    /// - Returns: Subview with tag if any
    func subview(with tag: Int) -> UIView? {
        subviews.first(where: { $0.tag == tag })
    }
    
    func addLoadingView() -> LoadingContainer {
        if let loadingContainer = getLoadingView() {
            return loadingContainer
        }
        
        let loadingContainer = LoadingContainer()
        loadingContainer.tag = loadingContainerTag
        addSubview(loadingContainer)
        loadingContainer.fillSuperview()
        
        return loadingContainer
    }
    
    func removeLoadingView() {
        getLoadingView()?.removeFromSuperview()
    }
    
    func getLoadingView() -> LoadingContainer? {
        subview(with: loadingContainerTag) as? LoadingContainer
    }
    
    func showLoadingView() {
        getLoadingView()?.show()
    }
    
    func hideLoadingView() {
        getLoadingView()?.hide()
    }
}
