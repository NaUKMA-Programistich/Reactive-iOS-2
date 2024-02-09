import Logging
import RxSwift
import UIKit

final class ViewController: UIViewController {
    private var viewModel = ViewModel()
    private let dBagVC = DisposeBag()
    
    private let logger = Logger(label: "ViewController")

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info("#viewDidLoad")
        
        view.addSubview(buildView)
        setupConstraints()
        logger.info("#viewDidLoad setup view")
        
        viewModel
            .state
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: onVMChange)
            .disposed(by: dBagVC)
    }
    
    private func onVMChange(state: ViewModel.State) {
        logger.info("#onVMChange \(state)")
        switch state {
        case .load(let image, let fact):
            imageView.image = UIImage(data: image)
            textView.text = fact
        case .loading:
            imageView.image = UIImage(named: "Placeholder")
            textView.text = "Loading, please wait..."
        case .none:
            imageView.image = UIImage(systemName: "figure.roll.runningpace")
            textView.text = "Try"
        }
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textView: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonView: UIButton = {
        let buttonView = UIButton()
        buttonView.setTitle("Generate Cat Story", for: .normal)
        buttonView.backgroundColor = .systemBlue
        buttonView.layer.cornerRadius = 12
        buttonView.addTarget(nil, action: #selector(processButton), for: .touchUpInside)
        buttonView.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        return buttonView
    }()
    
    @objc private func processButton() {
        viewModel.action.onNext(())
    }
 
    private lazy var buildView: UIView = {
        let stackView = UIStackView()
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(buttonView)

        stackView.spacing = 10
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
   
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 400),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            
            buildView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buildView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

#Preview {
    return ViewController()
}


