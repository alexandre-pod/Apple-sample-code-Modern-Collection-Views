/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Section headers and footers example
*/

import Cocoa

class NestedGroupsWindowController: NSWindowController {

    private let mainSection = NSString(string: "main")

    private var dataSource: NSCollectionViewDiffableDataSourceReference! = nil
    @IBOutlet weak var groupsCollectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension NestedGroupsWindowController {

    //   +-----------------------------------------------------+
    //   | +---------------------------------+  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     1     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  +-----------+  |
    //   | |               0                 |                 |
    //   | |                                 |  +-----------+  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |     2     |  |
    //   | |                                 |  |           |  |
    //   | |                                 |  |           |  |
    //   | +---------------------------------+  +-----------+  |
    //   +-----------------------------------------------------+

    private func createLayout() -> NSCollectionViewLayout {
        let layout = NSCollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in

            let leadingItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                                   heightDimension: .fractionalHeight(1.0)))
            leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            let trailingItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(0.3)))
            trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            let trailingGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitem: trailingItem, count: 2)

            let nestedGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(0.4)),
                subitems: [leadingItem, trailingGroup])
            let section = NSCollectionLayoutSection(group: nestedGroup)
            return section

        }
        return layout
    }
}

extension NestedGroupsWindowController {
   private func configureHierarchy() {
        let textItemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        groupsCollectionView.register(textItemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        let listItemNib = NSNib(nibNamed: "ListItem", bundle: nil)
        groupsCollectionView.register(listItemNib, forItemWithIdentifier: ListItem.reuseIdentifier)

        groupsCollectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference(collectionView: groupsCollectionView, itemProvider: {
            (collectionView: NSCollectionView, indexPath: IndexPath, identifier: Any) -> NSCollectionViewItem? in
            if let item = collectionView.makeItem(
                withIdentifier: TextItem.reuseIdentifier, for: indexPath) as? TextItem {
                item.textField?.stringValue = "\(indexPath.section), \(indexPath.item)"
                if let box = item.view as? NSBox {
                    box.cornerRadius = 8
                }
                return item
            } else {
                fatalError("Cannot create new item")
            }
        })

        // initial data
        let snapshot = NSDiffableDataSourceSnapshotReference()
        snapshot.appendSections(withIdentifiers: [mainSection])
        snapshot.appendItems(withIdentifiers: Array(0..<100).map { NSNumber(value: $0) })
        dataSource.applySnapshot(snapshot, animatingDifferences: false)

    }
}
