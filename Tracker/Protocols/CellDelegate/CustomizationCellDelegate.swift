import UIKit

protocol CustomizationCellDelegate: AnyObject {
    func customizationCell(didChangeEmoji emoji: String)
    func customizationCell(didChangeColor color: UIColor?)
}

