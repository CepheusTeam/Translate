//
//  GoogleModel.swift
//  Dummies-Part1
//
//  Created by sunny on 2017/5/6.
//  Copyright © 2017年 CepheusSun. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class GoogleModel {
    
    func createGoogleDataObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            
            let session = URLSession.shared
            let task = session.dataTask(with: URL(string: "https://www.google.com")!) { (data, response, error) in
                
                // 我们需要在主线程中更新
                DispatchQueue.main.async {
                    if let err = error {
                        // 如果请求失败, 直接发处失败的事件
                        observer.onError(err)
                    } else {
                        // 解析数据
                        if let googleString = String(data: data!, encoding: .ascii) {
                            // 将数据发送出去
                            observer.onNext(googleString)
                        } else {
                            // 如果解析失败发送失败的事件
                            observer.onNext("Error! Unable to parse the response data from google!")
                        }
                        // 结束这个序列
                        observer.onCompleted()
                    }
                }
            }
            task.resume()
            
            // 返回一个 AnonymousDisposable
            return Disposables.create(with: {
                // 取消请求
                task.cancel()
            })
        })
    }
}

