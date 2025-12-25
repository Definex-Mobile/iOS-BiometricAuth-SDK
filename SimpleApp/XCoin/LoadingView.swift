import Lottie
import UIKit

class LoadingView: UIView {
    
    private(set) lazy var animatedImageView: LottieAnimationView = {
        let view = LottieAnimationView(name: "loading")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Public

extension LoadingView {
    func showIn(view: UIView?) {
        guard let view = view else { return }
        
        animatedImageView.play()
        
        view.endEditing(true)
        frame = view.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(self)
    }
}

// MARK: - Private

private extension LoadingView {
    func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let container = UIView()
        container.backgroundColor = .white
        container.clipsToBounds = true
        container.layer.cornerRadius = 20
        
        addSubview(container)
        container.addSubview(animatedImageView)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin: CGFloat = 20
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.widthAnchor.constraint(equalTo: container.heightAnchor),
            
            animatedImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2),
            animatedImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: margin),
            animatedImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -1.0 * margin),
            animatedImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: margin),
            animatedImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -1.0 * margin)
        ])
    }
}

final class LoadingContainer: UIView {
  private lazy var loadingAnimationView: LottieAnimationView = {
    let view = LottieAnimationView(name: "loading")
    view.loopMode = .loop
    view.contentMode = .scaleAspectFit

    return view
  }()

  var showBackgroundOverlay: Bool = true {
    didSet {
      backgroundColor = showBackgroundOverlay ?
        UIColor.black.withAlphaComponent(0.3) :
        UIColor.clear
    }
  }

  var isClickable: Bool = false

  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }

  private func initialize() {
    addSubview(loadingAnimationView)

    layer.zPosition = 1
    isUserInteractionEnabled = false

    // Add Constraints
    loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      loadingAnimationView.widthAnchor.constraint(equalToConstant: 45),
      loadingAnimationView.heightAnchor.constraint(equalToConstant: 21),
      loadingAnimationView.centerXAnchor.constraint(equalTo: centerXAnchor),
      loadingAnimationView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
    

    setNeedsUpdateConstraints()

    // Initialize
    hide()
  }

  func toggle(show: Bool) {
    if show {
      self.show()
    } else {
      hide()
    }
  }

  func hide() {
    isHidden = true
    isUserInteractionEnabled = false
    loadingAnimationView.stop()
  }

  func show() {
    isUserInteractionEnabled = isClickable
    isHidden = false
    loadingAnimationView.play()
  }
}
