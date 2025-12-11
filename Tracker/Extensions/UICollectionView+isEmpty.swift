import UIKit

extension UICollectionView {
    
    var isEmpty: Bool {
        for section in 0..<numberOfSections {
            if numberOfItems(inSection: section) > 0 {
                return false
            }
        }
        return true
    }
    
}
