/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A two column grid described by compositional layout
*/

import Cocoa

class TwoColumnWindowController: NSWindowController {

    private let mainSection = NSString(string: "main")

    private var dataSource: NSCollectionViewDiffableDataSourceReference<NSString, NSNumber>! = nil
    @IBOutlet weak var columnCollectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension TwoColumnWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension TwoColumnWindowController {
    private func configureHierarchy() {
        let itemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        columnCollectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        columnCollectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference
            <NSString, NSNumber>(collectionView: columnCollectionView, itemProvider: {
                (collectionView: NSCollectionView,
                indexPath: IndexPath,
                identifier: NSNumber) -> NSCollectionViewItem? in
            let item = collectionView.makeItem(withIdentifier: TextItem.reuseIdentifier, for: indexPath)
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
