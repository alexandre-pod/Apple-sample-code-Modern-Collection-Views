/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Shows how to use NSCollectionLayoutSupplementaryItems to badge items
*/

import Cocoa

class ItemBadgeSupplementaryWindowController: NSWindowController {

    static let badgeElementKind = "badge-element-kind"
    static let badgeSupplementaryViewReuseIdentifier = NSUserInterfaceItemIdentifier("badge-reuse-identifier")
    private let mainSection = NSString(string: "main")

    class Model {
        let title: String
        let badgeCount: Int

        init(title: String, badgeCount: Int) {
            self.title = title
            self.badgeCount = badgeCount
        }

        let identifier = UUID()
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }

    private var dataSource: NSCollectionViewDiffableDataSourceReference<NSString, Model>! = nil
    @IBOutlet weak var itemCollectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension ItemBadgeSupplementaryWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: 0.3, y: -0.3))
        let badge = NSCollectionLayoutSupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(20),
                                               heightDimension: .absolute(20)),
            elementKind: ItemBadgeSupplementaryWindowController.badgeElementKind, containerAnchor: badgeAnchor)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.22),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)

        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ItemBadgeSupplementaryWindowController {
    private func configureHierarchy() {
        let itemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        itemCollectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        let badgeSupplementaryNib = NSNib(nibNamed: "BadgeSupplementaryView", bundle: nil)
        itemCollectionView.register(badgeSupplementaryNib,
                    forSupplementaryViewOfKind: ItemBadgeSupplementaryWindowController.badgeElementKind,
                    withIdentifier: ItemBadgeSupplementaryWindowController.badgeSupplementaryViewReuseIdentifier)

        itemCollectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference
            <NSString, Model>(collectionView: itemCollectionView, itemProvider: {
            (collectionView: NSCollectionView, indexPath: IndexPath, model: Model) -> NSCollectionViewItem? in
            let item = collectionView.makeItem(withIdentifier: TextItem.reuseIdentifier, for: indexPath)
            item.textField?.stringValue = model.title
            if let box = item.view as? NSBox {
                box.cornerRadius = 8
            }
            let shadow = NSShadow()
            shadow.shadowOffset = NSSize(width: 2, height: -2)
            shadow.shadowBlurRadius = 2
            item.view.shadow = shadow
            return item
        })
        dataSource.supplementaryViewProvider = {
            [weak self] (collectionView: NSCollectionView, kind: String, indexPath: IndexPath) -> NSView? in
            guard let self = self, let model = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
            let hasBadgeCount = model.badgeCount > 0
            let badgeView = collectionView.makeSupplementaryView(
                ofKind: kind,
                withIdentifier: ItemBadgeSupplementaryWindowController.badgeSupplementaryViewReuseIdentifier,
                for: indexPath)
            if let box = badgeView as? NSBox {
                if let label = box.contentView?.subviews.first as? NSTextField {
                    label.stringValue = "\(model.badgeCount)"
                }
            }
            badgeView.isHidden = !hasBadgeCount
            return badgeView
        }

        // initial data
        let snapshot = NSDiffableDataSourceSnapshotReference<NSString, Model>()
        snapshot.appendSections(withIdentifiers: [mainSection])
        let models = (0..<100).map { Model(title: "\($0)", badgeCount: Int.random(in: 0..<3)) }
        snapshot.appendItems(withIdentifiers: models)
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
    }
}

extension NSColor {
    static var cornflowerBlue: NSColor {
        return NSColor(displayP3Red: 85.0 / 255.0, green: 151.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    }
}
