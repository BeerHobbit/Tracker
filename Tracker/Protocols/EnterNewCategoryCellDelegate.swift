protocol EnterNewCategoryCellDelegate: AnyObject {
    func enterNewCategoryCell(didChangeText text: String)
    func updateCellLayout()
}
