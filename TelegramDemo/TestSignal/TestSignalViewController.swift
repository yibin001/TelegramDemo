//
//  TestSignalViewController.swift
//  TelegramDemo
//
//  Created by qmk on 2024/8/19.
//

import UIKit
import SwiftSignalKit

enum Box {
    case known(CGFloat)
    case unknown
}

class TestSignalViewController: UIViewController {
    //create a button
    private let button = UIButton()
    
    let box = Box.known(100)
    let box2 = Box.unknown
    
    let _contentsReady = ValuePromise<Bool>()
    public var contentsReady: Signal<Bool, NoError> {
        return _contentsReady.get()
    }
    
    private let _ready = ValuePromise<Bool>()
    public var ready: Signal<Bool, NoError> {
        return _ready.get()
    }
    
    private let _userName = ValuePromise<String>()
    public var userName: Signal<String, NoError> {
        return _userName.get()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .blue

        //add button to view
        self.view.addSubview(button)
        button.setTitle("Click me", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        let result = 5 |> { $0 * 2} |> { $0 + 2}
        
        print(result)
        
        
        let signal = Signal<Int, NoError> { subscriber in
            subscriber.putNext(1)
            
            Queue.mainQueue().after(1) {
                subscriber.putNext(2)
                subscriber.putCompletion()
            }
            
            return ActionDisposable {
                print("disposed")
            }
        }
        
        let disposable = signal.start { value in
            print("received value:\(value)")
        } completed: {
            print("signal completed")
        }
        
        contentsReady.start { value in
            print("contentsReady value is \(value)")
        }
        
//        (contentsReady |> map({ value in
//            return "hello \(value)"
//        }) |> deliverOnMainQueue).start { value in
//            print("value is \(value)")
//        }
        
        contentsReady |> map { value in
            return "hello \(value)"
        } |> afterNext({ value in
            print("value is \(value)")
        })
        
//        combineLatest([contentsReady, ready]).start { value in
//            print(value[0], value[1])
//        }
        
//        let combinedSignal = combineLatest(contentsReady, ready, userName) |> mapToQueue {(contentsReady, ready, userName) -> Signal<String, NoError> in
//            
//            let str = "combine:\(contentsReady) \(ready) \(userName)"
//            
//            return Signal { subscriber in
//                subscriber.putNext(str)
//                subscriber.putCompletion()
//                
//                return ActionDisposable {
//                    
//                }
//            }
//        }
        
        let combinedSignal = combineLatest(contentsReady, ready, userName) |> mapToSignal {(contentsReady, ready, userName) -> Signal<String, NoError> in
            
            let str = "combine:\(contentsReady) \(ready) \(userName)"
            
            return Signal { subscriber in
                subscriber.putNext(str)
                subscriber.putCompletion()
                
                return ActionDisposable {
                    
                }
            }
        }
        
        (combinedSignal |> distinctUntilChanged).start { str in
            print("received:\(str)")
        }
        
        switch box2 {
        case .known(let value):
            print("value is \(value)")
        case .unknown:
            print("unknown")
            
        }
        
        let testSignal:Signal<String, NoError> = Signal.single("google")
        
        let afterSignal = (testSignal |> afterNext({ value in
            print("afterNext \(value)")
        }))
        
        afterSignal.start { value in
            print("getValue \(value)")
        }
        
    }
    
    var x = true

    @objc func buttonClick() {
        if (x) {
            _contentsReady.set(true)
        } else {
            _contentsReady.set(false)
        }
        
        _ready.set(true)
        
        _userName.set("Beckham")
        
        x = !x
    }
}
