//
//  ViewController.swift
//  Dummies-Part1
//
//  Created by sunny on 2017/5/6.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {


    // 通常就是这样创建 DisposeBag 的
    // 当这个 controller 被释放掉的时候，disposebag
    // 也会释放掉, 并且所有 bag 中的元素都会调用 dispose() 方法
    let disposeBag = DisposeBag()
    let model = GoogleModel()
    
    @IBOutlet weak var googleText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 记住使用 [weak self] 或者 [unowned self] 来避免循环引用
        model.createGoogleDataObservable()
            .subscribe(onNext: { [weak self] (element) in
                self?.googleText.text = element
            }).addDisposableTo(disposeBag)
    }
}

