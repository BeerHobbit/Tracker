import UIKit

@objc
final class ColorTransformer: NSSecureUnarchiveFromDataTransformer {
    
    override class var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            ColorTransformer(),
            forName: NSValueTransformerName(String(describing: ColorTransformer.self))
        )
    }
    
}
