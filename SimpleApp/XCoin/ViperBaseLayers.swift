import UIKit

// MARK: - Base Viper Layers

protocol BaseView: AnyObject {
  func showLoading()
  func hideLoading()
  func showError(_ error: Error)
  func setUserInteractionEnabled(_ enabled: Bool)
}

protocol BaseInteractor { }

protocol ErrorReceiver: AnyObject {
  func didReceiveError(_ error: Error)
}

protocol BasePresenter: ErrorReceiver {
  var _view: BaseView? { get }
  func notifyViewLoaded()
  func notifyViewWillAppear()
  func notifyViewDidAppear()
  func notifyViewWillDisappear()
  func notifyViewDidDisappear()
}

protocol BaseEntity { }

protocol BaseRouter {
  func navigateToDeviceSettings()
}

// MARK: - Extensions
extension BaseView {
  
}

extension BaseView where Self: UIView {
  
  func showLoading() {
    showLoadingView()
  }
  
  func hideLoading() {
    hideLoadingView()
  }
  
  func showError(_ error: Error) {
    
  }
  
  func setUserInteractionEnabled(_ enabled: Bool) {
    isUserInteractionEnabled = enabled
  }
}

extension BaseView where Self: UIViewController {
  
  func showLoading() {
    if self.navigationController != nil {
      if getLoadingView() != nil { return } // Loading is already active
      
      guard let v = UIApplication.shared.keyWindow else { return }
      let loadingView = LoadingView()
      loadingView.showIn(view: v)
      
    } else {
      showLoading(true)
    }
  }
  
  func hideLoading() {
    guard navigationController != nil, let loadingView = getLoadingView() else {
      showLoading(false)
      return
    }
    
    loadingView.removeFromSuperview()
  }
  
  func showError(_ error: Error) {
      let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      present(alert, animated: true)
  }
  
  private func getLoadingView() -> LoadingView? {
    UIApplication.shared.keyWindow?.subviews.first(where: { $0 is LoadingView }) as? LoadingView
  }
  
  func setUserInteractionEnabled(_ enabled: Bool) {
    view.isUserInteractionEnabled = enabled
  }
}

extension BasePresenter {
  
  func didReceiveError(_ error: Error) {
    _view?.hideLoading()
    _view?.showError(error)
  }
  
  func notifyViewLoaded() {}
  func notifyViewWillAppear() {}
  func notifyViewDidAppear() {}
  func notifyViewWillDisappear() {}
  func notifyViewDidDisappear() {}
}

extension BaseRouter {
  
  func navigateToDeviceSettings() {
    UIApplication.shared.open(
      URL(string: UIApplication.openSettingsURLString)!,
      options: [:],
      completionHandler: nil
    )
  }
}
