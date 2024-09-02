import Foundation
import UIKit

public final class Button: Component {
    public let content: AnyComponent<Empty>
    public let minSize: CGSize?
    public let tag: AnyObject?
    public let automaticHighlight: Bool
    public let isEnabled: Bool
    public let isExclusive: Bool
    public let action: () -> Void
    public let holdAction: (() -> Void)?
    public let highlightedAction: ActionSlot<Bool>?

    convenience public init(
        content: AnyComponent<Empty>,
        isEnabled: Bool = true,
        automaticHighlight: Bool = true,
        action: @escaping () -> Void,
        highlightedAction: ActionSlot<Bool>? = nil
    ) {
        self.init(
            content: content,
            minSize: nil,
            tag: nil,
            automaticHighlight: automaticHighlight,
            isEnabled: isEnabled,
            action: action,
            holdAction: nil,
            highlightedAction: highlightedAction
        )
    }
    
    private init(
        content: AnyComponent<Empty>,
        minSize: CGSize? = nil,
        tag: AnyObject? = nil,
        automaticHighlight: Bool = true,
        isEnabled: Bool = true,
        isExclusive: Bool = true,
        action: @escaping () -> Void,
        holdAction: (() -> Void)?,
        highlightedAction: ActionSlot<Bool>?
    ) {
        self.content = content
        self.minSize = minSize
        self.tag = tag
        self.automaticHighlight = automaticHighlight
        self.isEnabled = isEnabled
        self.isExclusive = isExclusive
        self.action = action
        self.holdAction = holdAction
        self.highlightedAction = highlightedAction
    }
    
    public func minSize(_ minSize: CGSize?) -> Button {
        return Button(
            content: self.content,
            minSize: minSize,
            tag: self.tag,
            automaticHighlight: self.automaticHighlight,
            isEnabled: self.isEnabled,
            isExclusive: self.isExclusive,
            action: self.action,
            holdAction: self.holdAction,
            highlightedAction: self.highlightedAction
        )
    }
    
    public func withIsExclusive(_ isExclusive: Bool) -> Button {
        return Button(
            content: self.content,
            minSize: self.minSize,
            tag: self.tag,
            automaticHighlight: self.automaticHighlight,
            isEnabled: self.isEnabled,
            isExclusive: isExclusive,
            action: self.action,
            holdAction: self.holdAction,
            highlightedAction: self.highlightedAction
        )
    }
    
    
    public func withHoldAction(_ holdAction: (() -> Void)?) -> Button {
        return Button(
            content: self.content,
            minSize: self.minSize,
            tag: self.tag,
            automaticHighlight: self.automaticHighlight,
            isEnabled: self.isEnabled,
            isExclusive: self.isExclusive,
            action: self.action,
            holdAction: holdAction,
            highlightedAction: self.highlightedAction
        )
    }
    
    public func tagged(_ tag: AnyObject) -> Button {
        return Button(
            content: self.content,
            minSize: self.minSize,
            tag: tag,
            automaticHighlight: self.automaticHighlight,
            isEnabled: self.isEnabled,
            isExclusive: self.isExclusive,
            action: self.action,
            holdAction: self.holdAction,
            highlightedAction: self.highlightedAction
        )
    }
    
    public static func ==(lhs: Button, rhs: Button) -> Bool {
        if lhs.content != rhs.content {
            return false
        }
        if lhs.minSize != rhs.minSize {
            return false
        }
        if lhs.tag !== rhs.tag {
            return false
        }
        if lhs.automaticHighlight != rhs.automaticHighlight {
            return false
        }
        if lhs.isEnabled != rhs.isEnabled {
            return false
        }
        if lhs.isExclusive != rhs.isExclusive {
            return false
        }
        return true
    }
    
    public final class View: UIButton, ComponentTaggedView {
        private let contentView: ComponentHostView<Empty>
        
        public var content: UIView? {
            return self.contentView.componentView
        }
        
        private var component: Button?
        private var currentIsHighlighted: Bool = false {
            didSet {
                guard let component = self.component else {
                    return
                }
                if self.currentIsHighlighted != oldValue {
                    if component.automaticHighlight {
                        self.updateAlpha(transition: .immediate)
                    }
                    component.highlightedAction?.invoke(self.currentIsHighlighted)
                }
            }
        }
        
        private func updateAlpha(transition: ComponentTransition) {
            guard let component = self.component else {
                return
            }
            let alpha: CGFloat
            if component.isEnabled {
                if component.automaticHighlight {
                    alpha = self.currentIsHighlighted ? 0.6 : 1.0
                } else {
                    alpha = 1.0
                }
            } else {
                alpha = 0.3
            }
            transition.setAlpha(view: self.contentView, alpha: alpha)
        }
        
        private var holdActionTriggerred: Bool = false
        private var holdActionTimer: Timer?
        
        override init(frame: CGRect) {
            self.contentView = ComponentHostView<Empty>()
            self.contentView.isUserInteractionEnabled = false
            self.contentView.layer.allowsGroupOpacity = true
            
            super.init(frame: frame)
            
            self.addSubview(self.contentView)
            
            self.addTarget(self, action: #selector(self.pressed), for: .touchUpInside)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            self.holdActionTimer?.invalidate()
        }
        
        public func matches(tag: Any) -> Bool {
            if let component = self.component, let componentTag = component.tag {
                let tag = tag as AnyObject
                if componentTag === tag {
                    return true
                }
            }
            return false
        }
        
        @objc private func pressed() {
            if self.holdActionTriggerred {
                self.holdActionTriggerred = false
            } else {
                self.component?.action()
            }
        }
        
        override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
            self.currentIsHighlighted = true
            
            self.holdActionTriggerred = false
            
            if self.component?.holdAction != nil {
                self.holdActionTriggerred = true
                self.component?.action()
                
                self.holdActionTimer?.invalidate()
                if #available(iOS 10.0, *) {
                    let holdActionTimer = Timer(timeInterval: 0.5, repeats: false, block: { [weak self] _ in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.holdActionTimer?.invalidate()
                        strongSelf.component?.holdAction?()
                        strongSelf.beginExecuteHoldActionTimer()
                    })
                    self.holdActionTimer = holdActionTimer
                    RunLoop.main.add(holdActionTimer, forMode: .common)
                }
            }
            
            return super.beginTracking(touch, with: event)
        }
        
        private func beginExecuteHoldActionTimer() {
            self.holdActionTimer?.invalidate()
            if #available(iOS 10.0, *) {
                let holdActionTimer = Timer(timeInterval: 0.1, repeats: true, block: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.component?.holdAction?()
                })
                self.holdActionTimer = holdActionTimer
                RunLoop.main.add(holdActionTimer, forMode: .common)
            }
        }
        
        override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
            self.currentIsHighlighted = false
            
            self.holdActionTimer?.invalidate()
            self.holdActionTimer = nil
            
            super.endTracking(touch, with: event)
        }
        
        override public func cancelTracking(with event: UIEvent?) {
            self.currentIsHighlighted = false
            
            self.holdActionTimer?.invalidate()
            self.holdActionTimer = nil
            
            super.cancelTracking(with: event)
        }
        
        func update(component: Button, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
            let contentSize = self.contentView.update(
                transition: transition,
                component: component.content,
                environment: {},
                containerSize: availableSize
            )
            
            var size = contentSize
            if let minSize = component.minSize {
                size.width = max(size.width, minSize.width)
                size.height = max(size.height, minSize.height)
            }
            
            self.component = component
            
            self.updateAlpha(transition: transition)
            self.isEnabled = component.isEnabled
            self.isExclusiveTouch = component.isExclusive
            
            transition.setFrame(view: self.contentView, frame: CGRect(origin: CGPoint(x: floor((size.width - contentSize.width) / 2.0), y: floor((size.height - contentSize.height) / 2.0)), size: contentSize), completion: nil)
            
            return size
        }
    }
    
    public func makeView() -> View {
        return View(frame: CGRect())
    }
    
    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
        view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}
