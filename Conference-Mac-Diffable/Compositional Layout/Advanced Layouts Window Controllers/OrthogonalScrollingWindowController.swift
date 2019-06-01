/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Orthogonal scrolling section example
*/

import Cocoa

class OrthogonalScrollingWindowController: NSWindowController {

    private var dataSource: NSCollectionViewDiffableDataSourceReference<NSNumber, NSNumber>! = nil
    @IBOutlet weak var orthCollectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension OrthogonalScrollingWindowController {

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

        let leadingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.7),
            heightDimension: .fractionalHeight(1.0)))
        leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let trailingItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.3)))
        trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                              heightDimension: .fractionalHeight(1.0)),
            subitem: trailingItem, count: 2)

        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.4),
                                              heightDimension: .fractionalHeight(1.0)),
            subitems: [leadingItem, trailingGroup])
        let section = NSCollectionLayoutSection(group: containerGroup)
        section.orthogonalScrollingBehavior = .continuous

        let layout = NSCollectionViewCompositionalLayout(section: section)

        return layout
    }
}

extension OrthogonalScrollingWindowController {
   private func configureHierarchy() {
        let textItemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        orthCollectionView.register(textItemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        let listItemNib = NSNib(nibNamed: "ListItem", bundle: nil)
        orthCollectionView.register(listItemNib, forItemWithIdentifier: ListItem.reuseIdentifier)

        orthCollectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference
            <NSNumber, NSNumber>(collectionView: orthCollectionView, itemProvider: {
            (collectionView: NSCollectionView, indexPath: IndexPath, identifier: NSNumber) -> NSCollectionViewItem? in
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
        let snapshot = NSDiffableDataSourceSnapshotReference<NSNumber, NSNumber>()
        snapshot.appendSections(withIdentifiers: [NSNumber(value: 0)])
        snapshot.appendItems(withIdentifiers: Array(0..<30).map { NSNumber(value: $0) })
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
    }
}
