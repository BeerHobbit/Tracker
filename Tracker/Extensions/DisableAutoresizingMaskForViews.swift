import UIKit

extension UIViewController {
    func disableAutoresizingMaskForViews(_ views: [UIView]) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

extension UICollectionViewCell {
    func disableAutoresizingMaskForViews(_ views: [UIView]) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

extension UITableViewCell {
    func disableAutoresizingMaskForViews(_ views: [UIView]) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
