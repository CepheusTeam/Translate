//
//  ViewController.swift
//  RxSwiftSafetyManual
//
//  Created by sunny on 2017/5/7.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    
    let viewModel = ViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var priceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let lable = UILabel()
        
        
        viewModel.importantText
            .catchErrorJustReturn("default text")
            .bind(to: lable.rx.text)
            .addDisposableTo(disposeBag)
        
        
        viewModel.importantText
            .asDriver(onErrorJustReturn: "default text")
            .drive(lable.rx.text)
            .addDisposableTo(disposeBag)
        
        
        viewModel.priceString
            .subscribe(onNext: {[unowned self] (text) in
                self.priceLabel.text = text
            }).addDisposableTo(disposeBag)
        
        
        // 这个例子并不准确, 正确的例子是在vc 之外的一个类中。
        let viewController = ViewController()
        viewModel.priceString
            .subscribe(onNext: {[weak viewController] (text) in
                viewController?.priceLabel.text = text
            }).addDisposableTo(disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

