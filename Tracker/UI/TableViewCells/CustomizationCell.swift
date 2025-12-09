import UIKit

final class CustomizationCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "CustomizationCellReuseIdentifier"
    
    // MARK: - Delegate
    
    weak var delegate: CustomizationCellDelegate?
    
    // MARK: - Types
    
    private enum Section {
        case emojis(EmojisSection)
        case colors(ColorsSection)
    }
    
    // MARK: - Views
    
    private lazy var customizationCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseID)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseID)
        collectionView.register(CustomizationHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomizationHeader.reuseID)
        
        return collectionView
    }()
    
    // MARK: - State
    
    private var emoji: String = "" {
        didSet {
            delegate?.customizationCell(didChangeEmoji: emoji)
        }
    }
    
    private var color: UIColor? = nil {
        didSet {
            delegate?.customizationCell(didChangeColor: color)
        }
    }
    
    // MARK: - Private Properties
    
    private let layoutParams = LayoutParams(
        cellCount: 6,
        leftInset: 18,
        rightInset: 18,
        cellSpacing: 5
    )
    
    private let sections: [Section] = [
        .emojis(
            EmojisSection(
                title: "Emoji",
                emojis: [
                    "🙂", "😻", "🌺", "🐶", "❤️", "😱",
                    "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                    "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
                ]
            )
        ),
        .colors(
            ColorsSection(
                title: "Цвет",
                colors: [
                    .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4,
                    .colorSelection5, .colorSelection6, .colorSelection7,.colorSelection8,
                    .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
                    .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16,
                    .colorSelection17, .colorSelection18
                ]
            )
        )
    ]
    
    private lazy var selectedIndexPaths: [IndexPath?] = Array(repeating: nil, count: sections.count)
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configDependencies()
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        layoutIfNeeded()
        let height = customizationCollectionView.collectionViewLayout.collectionViewContentSize.height
        return CGSize(width: targetSize.width, height: height)
    }
    
    // MARK: - Configure Dependencies
    
    private func configDependencies() {
        customizationCollectionView.dataSource = self
        customizationCollectionView.delegate = self
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(customizationCollectionView)
        setupConstraints()
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        customizationCollectionView.edgesToSuperview()
    }
    
}

// MARK: - UICollectionViewDataSource

extension CustomizationCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .emojis(let item): return item.emojis.count
        case .colors(let item): return item.colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .emojis(let item):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseID, for: indexPath) as? EmojiCell else {
                assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(EmojiCell.reuseID) as \(String(describing: EmojiCell.self))")
                return UICollectionViewCell()
            }
            cell.configure(emoji: item.emojis[indexPath.item])
            return cell
            
        case .colors(let item):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseID, for: indexPath) as? ColorCell else {
                assertionFailure("❌[dequeueReusableCell]: can't dequeue reusable cell with id: \(ColorCell.reuseID) as \(String(describing: ColorCell.self))")
                return UICollectionViewCell()
            }
            cell.configure(color: item.colors[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CustomizationHeader.reuseID,
            for: indexPath
        ) as? CustomizationHeader else { return UICollectionReusableView() }
        switch sections[indexPath.section] {
        case .emojis(let item):
            header.configure(title: item.title)
            return header
        case .colors(let item):
            header.configure(title: item.title)
            return header
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CustomizationCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - layoutParams.paddingWidth
        let cellWidth = availableWidth / CGFloat(layoutParams.cellCount)
        let cellHeight = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: layoutParams.leftInset, bottom: 40, right: layoutParams.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return layoutParams.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = CustomizationHeader(frame: CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 0))
        
        var title = ""
        switch sections[section] {
        case .emojis(let item):
            title = item.title
        case .colors(let item):
            title = item.title
        }
        
        headerView.configure(title: title)
        let targetSize = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height))
        let size = CGSize(width: targetSize.width, height: targetSize.height)
        
        return size
    }
    
}

// MARK: - UICollectionViewDelegate

extension CustomizationCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        
        if let oldIndexPath = selectedIndexPaths[section] {
            collectionView.deselectItem(at: oldIndexPath, animated: false)
        }
        selectedIndexPaths[section] = indexPath
        
        switch sections[section] {
        case .emojis(let item):
            emoji = item.emojis[indexPath.item]
        case .colors(let item):
            color = item.colors[indexPath.item]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        selectedIndexPaths[section] = nil
        
        switch sections[section] {
        case .emojis(_):
            emoji = ""
        case .colors(_):
            color = nil
        }
    }
    
}
