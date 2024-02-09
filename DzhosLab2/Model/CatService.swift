import Foundation
import RxSwift
import Logging

final class CatService {
    
    struct Fact: Codable {
        let fact: String
        let length: Int
    }
    
    enum CatError: Error {
        case simpleError
    }
    
    static let shared: CatService = .init()
    
    private let logger = Logger(label: "CatService")
    
    private init() {}
    
    func getRandomPhoto() -> Single<Data>{
        return createSingle(url: "https://cataas.com/cat")
    }
    
    func getRandomFact() -> Single<String> {
        return createSingle(url: "https://catfact.ninja/fact").map { jsonData in
            let dto = try JSONDecoder().decode(Fact.self, from: jsonData)
            return dto.fact
        }
    }
    
    private func createSingle(url: String) -> Single<Data> {
        return Single<Data>.create { single in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    self.logger.error("#createSingle by \(url) \(error)")
                    single(.failure(error))
                    return
                }
                
                if let data = data {
                    self.logger.info("#createSingle we have data")
                    single(.success(data))
                    return
                }
                
                self.logger.error("#createSinge single error")
                single(.failure(CatError.simpleError))
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
