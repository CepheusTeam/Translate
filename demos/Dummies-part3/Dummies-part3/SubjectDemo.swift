//
//  SubjectDemo.swift
//  Dummies-part3
//
//  Created by sunny on 2017/5/7.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class Subjectdemo {
    
    let disposeBag = DisposeBag()

    //MARK: - Subject
    
    func subjectTest()  {
        
        let subject = PublishSubject<String>()
        let observable: Observable<String> = subject
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        subject.onNext("Hey!")
        subject.onNext("I'm back!")
        
    }
    
    func subjectTest2() {
        let subject = PublishSubject<String>()
        let observable: Observable<String> = subject
        // 这个信号还没有被订阅, 所以这个值不回被接受到
        subject.onNext("Am I too early for the party?")
        
        observable
            .subscribe(onNext: { (text) in
                print(text)
            }).addDisposableTo(disposeBag)
        // 这个值发出来的时候已经有一个订阅者了, 所以这个值会打印出来
        subject.onNext("🎉🎉🎉")
    }
    
    //MARK: - PublishSubject
    
    func publishSubject() {
        let subject = PublishSubject<String>()
        let observable: Observable<String> = subject
        subject.onNext("Ignored...")
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        subject.onNext("Printed!")
    }
    
    //MARK: - ReplaySubject
    
    func replaySubject() {
        let subject = ReplaySubject<String>.create(bufferSize: 3)
        let observable: Observable<String> = subject

        subject.onNext("Not printed!")
        subject.onNext("Printed")
        subject.onNext("Printed!")
        subject.onNext("Printed!")
        
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        subject .onNext("Printed!")
        
    }
    
    //MARK: - BehaviorSubject

    func behaviorSubject () {
        let subject = BehaviorSubject<String>(value: "Initial value")
        let observable: Observable<String> = subject
        
        subject.onNext("Not printed!")
        subject.onNext("Not printed!")
        subject.onNext("Printed!")
        
        observable.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        subject.onNext("Printed!")
    }
    
    //MARK: - Binding

    func binding()  {
        let subject = PublishSubject<String>()
        let observable = Observable<String>.just("I'm being passed around 😲")
        subject.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        
        observable.subscribe { (event) in
            subject.on(event)
        }.addDisposableTo(disposeBag)
    }

    func binding2()  {
        let subject = PublishSubject<String>()
        let observable = Observable<String>.just("I'm being passed around 😲")
        subject.subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
        
        observable.bind(to: subject).addDisposableTo(disposeBag)
    }
    
    //MARK: - Variable
    
    func variableTest() {
        let googleString = Variable("currentString")
        // get
        print(googleString.value)
        // set
        googleString.value = "newString"
        // 订阅
        googleString.asObservable().subscribe(onNext: { (text) in
            print(text)
        }).addDisposableTo(disposeBag)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
