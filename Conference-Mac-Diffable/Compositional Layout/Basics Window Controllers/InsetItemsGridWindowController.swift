/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A list with inset item content described by compositional layout
*/

import Cocoa

class InsetItemsGridWindowController: NSWindowController {

    private let mainSection = NSString(string: "main")

    private var dataSource: NSCollectionViewDiffableDataSourceReference! = nil
    @IBOutlet weak var collectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension InsetItemsGridWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension InsetItemsGridWindowController {
    private func configureHierarchy() {
        let itemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        collectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        collectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference(collectionView: collectionView, itemProvider: {
                (collectionView: NSCollectionView,
                indexPath: IndexPath,
                identifier: Any) -> NSCollectionViewItem? in
            let item = collectionView.makeItem(withIdentifier: TextItem.reuseIdentifier, for: indexPath)
            item.textField?.stringValue = "\(identifier)"
            return item
        })

        // initial data
        let snapshot = NSDiffableDataSourceSnapshotReference()
        snapshot.appendSections(withIdentifiers: [mainSection])
        snapshot.appendItems(withIdentifiers: Array(0..<94).map { NSNumber(value: $0) })
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
    }
}
