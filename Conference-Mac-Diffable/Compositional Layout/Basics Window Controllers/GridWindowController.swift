/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A basic grid described by compositional layout
*/

import Cocoa

class GridWindowController: NSWindowController {

    private let mainSection = NSString(string: "main")

    private var dataSource: NSCollectionViewDiffableDataSourceReference! = nil
    @IBOutlet weak var gridCollectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension GridWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension GridWindowController {
    private func configureHierarchy() {
        let itemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        gridCollectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        gridCollectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference(collectionView: gridCollectionView, itemProvider: {
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
