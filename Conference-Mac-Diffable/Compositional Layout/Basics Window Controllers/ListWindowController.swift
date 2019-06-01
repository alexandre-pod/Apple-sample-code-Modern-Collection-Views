/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A basic list described by compositional layout
*/

import Cocoa

class ListWindowController: NSWindowController {

    private let mainSection = NSString(string: "main")

    private var dataSource: NSCollectionViewDiffableDataSourceReference<NSString, NSNumber>! = nil
    @IBOutlet weak var collectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension ListWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(20))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension ListWindowController {
    private func configureHierarchy() {
        let itemNib = NSNib(nibNamed: "ListItem", bundle: nil)
        collectionView.register(itemNib, forItemWithIdentifier: ListItem.reuseIdentifier)

        collectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference
            <NSString, NSNumber>(collectionView: collectionView, itemProvider: {
                (collectionView: NSCollectionView,
                indexPath: IndexPath,
                identifier: NSNumber) -> NSCollectionViewItem? in
            let item = collectionView.makeItem(withIdentifier: ListItem.reuseIdentifier, for: indexPath)
            item.textField?.stringValue = "\(identifier)"
            return item
        })

        // initial data
        let snapshot = NSDiffableDataSourceSnapshotReference<NSString, NSNumber>()
        snapshot.appendSections(withIdentifiers: [mainSection])
        snapshot.appendItems(withIdentifiers: Array(0..<94).map { NSNumber(value: $0) })
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
    }
}
