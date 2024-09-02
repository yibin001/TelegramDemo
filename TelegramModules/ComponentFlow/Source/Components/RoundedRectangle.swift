import Foundation
import UIKit

public final class RoundedRectangle: Component {
    public enum GradientDirection: Equatable {
        case horizontal
        case vertical
    }
    
    public let colors: [UIColor]
    public let cornerRadius: CGFloat?
    public let gradientDirection: GradientDirection
    public let stroke: CGFloat?
    public let strokeColor: UIColor?
    
    public convenience init(color: UIColor, cornerRadius: CGFloat?, stroke: CGFloat? = nil, strokeColor: UIColor? = nil) {
        self.init(colors: [color], cornerRadius: cornerRadius, stroke: stroke, strokeColor: strokeColor)
    }
    
    public init(colors: [UIColor], cornerRadius: CGFloat?, gradientDirection: GradientDirection = .horizontal, stroke: CGFloat? = nil, strokeColor: UIColor? = nil) {
        self.colors = colors
        self.cornerRadius = cornerRadius
        self.gradientDirection = gradientDirection
        self.stroke = stroke
        self.strokeColor = strokeColor
    }

    public static func ==(lhs: RoundedRectangle, rhs: RoundedRectangle) -> Bool {
        if lhs.colors != rhs.colors {
            return false
        }
        if lhs.cornerRadius != rhs.cornerRadius {
            return false
        }
        if lhs.gradientDirection != rhs.gradientDirection {
            return false
        }
        if lhs.stroke != rhs.stroke {
            return false
        }
        if lhs.strokeColor != rhs.strokeColor {
            return false
        }
        return true
    }
    
    public final class View: UIImageView {
        var component: RoundedRectangle?
        
        func update(component: RoundedRectangle, availableSize: CGSize, transition: ComponentTransition) -> CGSize {
            if self.component != component {
                let cornerRadius = component.cornerRadius ?? min(availableSize.width, availableSize.height) * 0.5
                
                if component.colors.count == 1, let color = component.colors.first {
                    let imageSize = CGSize(width: max(component.stroke ?? 0.0, cornerRadius) * 2.0, height: max(component.stroke ?? 0.0, cornerRadius) * 2.0)
                    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
                    if let context = UIGraphicsGetCurrentContext() {
                        if let strokeColor = component.strokeColor {
                            context.setFillColor(strokeColor.cgColor)
                        } else {
                            context.setFillColor(color.cgColor)
                        }
                        context.fillEllipse(in: CGRect(origin: CGPoint(), size: imageSize))
                        
                        if let stroke = component.stroke, stroke > 0.0 {
                            if let _ = component.strokeColor {
                                context.setFillColor(color.cgColor)
                            } else {
                                context.setBlendMode(.clear)
                            }
                            context.fillEllipse(in: CGRect(origin: CGPoint(), size: imageSize).insetBy(dx: stroke, dy: stroke))
                        }
                    }
                    self.image = UIGraphicsGetImageFromCurrentImageContext()?.stretchableImage(withLeftCapWidth: Int(cornerRadius), topCapHeight: Int(cornerRadius))
                    UIGraphicsEndImageContext()
                } else if component.colors.count > 1 {
                    let imageSize = availableSize
                    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
                    if let context = UIGraphicsGetCurrentContext() {
                        context.addPath(UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: imageSize), cornerRadius: cornerRadius).cgPath)
                        context.clip()

                        let colors = component.colors
                        let gradientColors = colors.map { $0.cgColor } as CFArray
                        let colorSpace = CGColorSpaceCreateDeviceRGB()
                        
                        var locations: [CGFloat] = []
                        let delta = 1.0 / CGFloat(colors.count - 1)
                        for i in 0 ..< colors.count {
                            locations.append(delta * CGFloat(i))
                        }
                        let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: &locations)!
                        context.drawLinearGradient(gradient, start: CGPoint(x: 0.0, y: 0.0), end: component.gradientDirection == .horizontal ? CGPoint(x: imageSize.width, y: 0.0) : CGPoint(x: 0.0, y: imageSize.height), options: CGGradientDrawingOptions())
                        
                        if let stroke = component.stroke, stroke > 0.0 {
                            context.resetClip()
                            
                            context.addPath(UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: imageSize).insetBy(dx: stroke, dy: stroke), cornerRadius: cornerRadius).cgPath)
                            context.setBlendMode(.clear)
                            context.fill(CGRect(origin: .zero, size: imageSize))
                        }
                    }
                    self.image = UIGraphicsGetImageFromCurrentImageContext()?.stretchableImage(withLeftCapWidth: Int(cornerRadius), topCapHeight: Int(cornerRadius))
                    UIGraphicsEndImageContext()
                }
            }

            return availableSize
        }
    }
    
    public func makeView() -> View {
        return View()
    }
    
    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<Empty>, transition: ComponentTransition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, transition: transition)
    }
}
