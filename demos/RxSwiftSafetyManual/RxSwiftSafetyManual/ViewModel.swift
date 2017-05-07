//
//  ViewModel.swift
//  RxSwiftSafetyManual
//
//  Created by sunny on 2017/5/7.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class ViewModel {
    
    
    let disposeBag = DisposeBag()
    
    let importantText: Observable<String>
    let priceString: Observable<String>
    
    init() {
        importantText = Observable.create({ (observer) -> Disposable in
            observer.onNext("🎁")
            return Disposables.create()
        })
        
        priceString = Observable.create({ (observer) -> Disposable in
            observer.onNext("🎁")
            return Disposables.create()
        })
    }
    
}
