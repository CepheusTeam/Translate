//
//  DemoFile.swift
//  Dummies-Part2
//
//  Created by sunny on 2017/5/6.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class DemoFile {
    
    let disposeBag = DisposeBag()
    let label = UILabel()
    func observerOnTest()  {
        
        //MARK: - part1
        _ = Observable<String>.create { (observer) -> Disposable in
            DispatchQueue.global(qos: .default).async {
                Thread.sleep(forTimeInterval: 10)
                DispatchQueue.main.async {
                    observer.onNext("Hello dummy 🐥")
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
        
        //MARK: - part2
        let observable = Observable<String>.create({ (observer) -> Disposable in
            DispatchQueue.global(qos: .default).async {
                Thread.sleep(forTimeInterval: 10)
                observer.onNext("Hello dummy 🐥")
                observer.onCompleted()
            }
            return Disposables.create()
        }).observeOn(MainScheduler.instance)
        
        observable.subscribe(onNext: { [weak self] (element) in
            self?.label.text = element
        }).addDisposableTo(disposeBag)
        
        
        //MARK: - part3
        
        let observable2 = Observable<String>.create { (observer) -> Disposable in
            Thread.sleep(forTimeInterval: 10)
            observer.onNext("Hello dummy 🐥")
            observer.onCompleted()
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
        
        observable2
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [weak self] (element) in
                self?.label.text = element
            }).addDisposableTo(disposeBag)
        
    }
    
    
    
    //MARK: - part4  map
    func mapTest()  {
        
        let observerable = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            return Disposables.create()
        }
        
        let boolObservable: Observable<Bool> = observerable.map{(element) -> Bool in
            if element == 0 {
                return false
            }
            return true
        }
        
        boolObservable.subscribe(onNext: { (boolElement) in
            print(boolElement)
        }).addDisposableTo(disposeBag)
        
    }
    
     //MARK: - part4  scan
    
    func scanTest()  {
        let observable = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("D")
            observer.onNext("U")
            observer.onNext("M")
            observer.onNext("M")
            observer.onNext("Y")
            return Disposables.create()
        }
        observable.scan("") { (lastValue, currentValue) -> String in
            return lastValue + currentValue
        }.subscribe(onNext: { (element) in
            print(element)
        }).addDisposableTo(disposeBag)
    }

    
    func scanTest2()  {
        let observable = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onNext(4)
            observer.onNext(5)
            return Disposables.create()
        }
        observable.scan(1) { (lastValue, currentValue) -> Int in
            return lastValue + currentValue
            }.subscribe(onNext: { (element) in
                print(element)
            }).addDisposableTo(disposeBag)
    }

    
    func scanTest3()  {
        let button = UIButton()
        button.rx.tap.scan(false) { last, new in
            return !last
        }.subscribe(onNext: { (element) in
            print("tap: \(element)")
        }).addDisposableTo(disposeBag)
    }
    
    
    //MARK: - part5  Filter
    
    func filterTest() {
        let observerable = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("🎁")
            observer.onNext("💩")
            observer.onNext("💩")
            observer.onNext("💩")
            observer.onNext("🎁")
            return Disposables.create()
        }
        observerable.filter { (element) -> Bool in
            return element == "🎁"
        }.subscribe(onNext: { (element) in
            print(element)
        }).addDisposableTo(disposeBag)
    }

    func debounceTest() {
        let observerable = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("🎁")
            observer.onNext("💩")
            observer.onNext("💩")
            observer.onNext("💩")
            observer.onNext("🎁")
            return Disposables.create()
        }
        observerable
            .debounce(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (element) in
                print(element)
            }).addDisposableTo(disposeBag)
    }
    
    
    //MARK: - part6  Merge
    
    func mergeTest() {
        
        let observable = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("🎁")
            observer.onNext("🎁")
            return Disposables.create()
        }
        let observable2 = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("💩")
            observer.onNext("💩")
            return Disposables.create()
        }
        Observable.of(observable, observable2).merge().subscribe(onNext: { (element) in
            print(element)
        }).addDisposableTo(disposeBag)
        
    }
    
    //MARK: - part7  Zip

    func zipTest()  {
        let observable = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("🎁")
            observer.onNext("🎁")
            return Disposables.create()
        }
        let observable2 = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("💩")
            observer.onNext("💩")
            return Disposables.create()
        }
        Observable.zip(observable ,observable2).subscribe(onNext: { (element) in
            print(element)
        }).addDisposableTo(disposeBag)
        
    }
    
    func zipTest2() {
        let observable = Observable<String>.create { (observer) -> Disposable in
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 3)
                observer.onNext("fetched from sever 1")
            }
            return Disposables.create()
        }
        let observable2 = Observable<String>.create { (observer) -> Disposable in
            DispatchQueue.main.async {
                Thread.sleep(forTimeInterval: 2)
                observer.onNext("fetched from sever 2")
            }
            return Disposables.create()
        }
        
        Observable.zip(observable, observable2)
            .subscribe(onNext: { (element) in
                print(element)
            }).addDisposableTo(disposeBag)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
