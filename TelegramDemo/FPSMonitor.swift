import Foundation
import UIKit

class FPSMonitor:NSObject {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: TimeInterval = 0
    private var frameCount: Int = 0
    
    override init() {
        super.init()
        
        displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        
        frameCount += 1
        let elapsed = link.timestamp - lastTimestamp
        if elapsed >= 1 {
            let fps = Double(frameCount) / elapsed
            print("FPS: \(Int(round(fps)))")
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
