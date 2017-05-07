//
//  SaftyDame.swift
//  RxSwiftSafetyManual
//
//  Created by sunny on 2017/5/7.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SaftyClass {
    
    let disposeBag = DisposeBag()
    
    //MARK: - Side Effects
    
    func sideEffects() {
        var counter = 1
        
        let observable = Observable<Int>.create { (observer) -> Disposable in
            // 这样写没有副作用
            observer.onNext(1)
            return Disposables.create()
        }
        
        let observableWithSideEffect = Observable<Int>.create { (observer) -> Disposable in
            // 这里就会有副作用: 这个 closure 改变了 counter 的值
            counter = counter + 1
            observer.onNext(counter)
            return Disposables.create()
        }
        
        
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)
        
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)
    }
    
    func resolution1()  {
        var counter = 1
        let observableWithSideEffect = Observable<Int>.create { (observer) -> Disposable in
            counter = counter + 1
            observer.onNext(counter)
            return Disposables.create()
        }.publish()
        // publish returns an observable with a shared subscription(hot).
        // It's not active yet
        
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)
        
        observableWithSideEffect
            .connect()
            .addDisposableTo(disposeBag)
        
    }

    func resolution2()  {
        var counter = 1
        let observableWithSideEffect = Observable<Int>.create { (observer) -> Disposable in
            counter = counter + 1
            observer.onNext(counter)
            return Disposables.create()
            }.shareReplay(1)
        
        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)

        observableWithSideEffect
            .subscribe(onNext: { (counter) in
                print(counter)
            }).addDisposableTo(disposeBag)

        /*
        observableWithSideEffect
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (counter) in
                // update UI
            }).addDisposableTo(disposeBag)
         */
        
    }
    

    
    
    
    
    
}
