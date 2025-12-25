//
//  UIViewController+Extension.swift
//  CoinX
//
//  Created by Mücahit Katırcı on 12.09.2023.
//

import UIKit

// MARK: - Loader
extension UIViewController {
  
  private func getLoadingView() -> LoadingView? {
    view.subviews.first(where: { $0 is LoadingView }) as? LoadingView
  }
  
  func showLoading(_ isLoading: Bool) {
    if isLoading {
      showLoadingView()
    } else {
      hideLoadingView()
    }
  }

  func showLoadingView() {
    if getLoadingView() != nil {
      // Loading is already active
      return
    }

    let loadingView = LoadingView()
    loadingView.showIn(view: view)
  }

  func hideLoadingView() {
    getLoadingView()?.removeFromSuperview()
  }
}

