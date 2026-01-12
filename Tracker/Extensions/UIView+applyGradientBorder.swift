import UIKit

extension UIView {
    
    func applyGradientBorder(
        colors: [UIColor],
        startPoint: CGPoint,
        endPoint: CGPoint,
        lineWidth: CGFloat,
        cornerRadius: CGFloat
    ) {
        layer.sublayers?
            .filter { $0.name == "GradientBorderLayer" }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "GradientBorderLayer"
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
            cornerRadius: cornerRadius
        ).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }
    
}
