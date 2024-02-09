import Logging
import RxSwift
import UIKit

final class ViewModel {
    private let logger = Logger(label: "ViewModel")
    
    private let dBagVM = DisposeBag()
    private let dBagService = DisposeBag()

    private let catService: CatService = .shared
    
    enum State {
        case none // for error and first screen
        case loading
        case load(Data, String)
    }
    
    public let state = BehaviorSubject<State>(value: .none)
    public let action = PublishSubject<Void>()
    
    init() {
        action
            .subscribe(onNext: onVCChange)
            .disposed(by: dBagVM)
    }
    
    private func onVCChange() {
        logger.info("#onVCChange")
        
        if case .loading = state.value {
            logger.info("Current state is loading, so, skip press button")
            return
        }
        state.onNext(.loading)
        
        Single.zip(
            catService.getRandomFact(),
            catService.getRandomPhoto()
        ).subscribe(onSuccess: { [weak self] (fact, image) in
            self?.logger.info("#onVCChange result: \(fact) \(image)")
            self?.state.onNext(.load(image, fact))
        }, onFailure: { [weak self] error in
            self?.logger.error("Error: \(error)")
            self?.state.onNext(.none)
        })
        .disposed(by: dBagService)
    }
}

extension BehaviorSubject {
    public var value: Element? {
        return try? self.value()
    }
}
