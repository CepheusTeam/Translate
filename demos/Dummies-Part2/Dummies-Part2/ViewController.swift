//
//  ViewController.swift
//  Dummies-Part2
//
//  Created by sunny on 2017/5/6.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    @IBOutlet weak var debounceButton: UIButton!
    
    @IBOutlet weak var demoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        debounceButton.rx.tap.asObservable()
            .debounce(10, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (element) in
                print("a")
            }).addDisposableTo(disposeBag);
        
        
        Observable<NSDate>.create { (observer) -> Disposable in
            DispatchQueue.global(qos: .default).async {
                while true {
                    Thread.sleep(forTimeInterval: 0.01)
                    observer.onNext(NSDate())
                }
            }
            return Disposables.create()
            }// 需要在主线程中刷新 UI
            .observeOn(MainScheduler.instance)
            // 我们只需要能够被2整除的事件
            .filter { (date) -> Bool in
                return Int(date.timeIntervalSince1970) % 2 == 0
            }
            // 将数据转换成颜色
            .map { (date) -> UIColor in
                let interval: Int = Int(date.timeIntervalSince1970)
                let color1 = CGFloat( Double(((interval * 1) % 255)) / 255.0)
                let color2 = CGFloat( Double(((interval * 2) % 255)) / 255.0)
                let color3 = CGFloat( Double(((interval * 3) % 255)) / 255.0)
                return UIColor(red: color1, green: color2, blue: color3, alpha: 1)
            }
            .subscribe(onNext: {[weak self] (color) in
                self?.demoView.backgroundColor = color
            }).addDisposableTo(disposeBag)
    }


}

