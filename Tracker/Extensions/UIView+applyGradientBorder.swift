import UIKit

extension UIView {
    /**
    Adds a gradient border around the view.
     
     The border is drawn using a `CAGradientLayer`
     masked by a `CAShapeLayer` to support rounded corners.
     
     - Parameters:
        - colors: Border gradient colors
        - startPoint: Start point of gradient
        - endPoint: End point of gradient
        - lineWidth: Border thickness
        - cornerRadius: Corner radius. In standard cases, use `yourView.layer.cornerRadius`.
     
     - Important: The method uses `bounds`, so it must be called after layout (for example, in `layoutSubviews` or after `layoutIfNeeded()`)
    */
    func applyGradientBorder(
        colors: [UIColor],
        startPoint: CGPoint,
        endPoint: CGPoint,
        lineWidth: CGFloat,
        cornerRadius: CGFloat
    ) {
        // Remove any previously added gradient border layer
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
        
        // Mask to render only the border
        gradientLayer.mask = shapeLayer
        layer.addSublayer(gradientLayer)
    }
    
}
