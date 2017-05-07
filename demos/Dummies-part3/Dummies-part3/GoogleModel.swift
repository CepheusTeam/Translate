//
//  GoogleModel.swift
//  Dummies-part3
//
//  Created by sunny on 2017/5/7.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class GoogleModel {
    let googleString = BehaviorSubject<String>(value: "")
    private let disposeBag = DisposeBag()
    
    
    func fetchNetString()  {
        let observable = Observable<String>.create { (observer) -> Disposable in
            let session = URLSession.shared
            let task = session.dataTask(with: URL(string: "https://www.google.com")!, completionHandler: { (data, response, error) in
                
                DispatchQueue.main.async {
                    if let err = error {
                        observer.onError(err)
                    } else {
                        let googleString = NSString(data: data!, encoding: 1) as String?
                        
                        observer.onNext(googleString!)
                        observer.onCompleted()
                    }
                }
            })
            task.resume()
            return Disposables.create{
                task.cancel()
            }
        }
        
        // Bind the observable to the subject
        observable.bind(to: googleString).addDisposableTo(disposeBag)

    }
    
    
}
