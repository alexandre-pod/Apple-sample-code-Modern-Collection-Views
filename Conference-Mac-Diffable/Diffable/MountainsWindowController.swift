/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Sample showing how we might create a searching UI using a diffable data source
*/

import Cocoa

class MountainsWindowController: NSWindowController {

    private let mainSection = NSString(string: "main")

    private let mountainsController = MountainsController()
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var collectionView: NSCollectionView!
    private var dataSource: NSCollectionViewDiffableDataSourceReference!
    private var nameFilter: String?

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
        performQuery(with: nil)
    }
}

extension MountainsWindowController {
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference(collectionView: collectionView) {
            (collectionView: NSCollectionView,
            indexPath: IndexPath,
            identifier: Any) -> NSCollectionViewItem? in
            let mountainItem = collectionView.makeItem(withIdentifier: TextItem.reuseIdentifier, for: indexPath)
            if let mountain = identifier as? MountainsController.Mountain {
                mountainItem.textField?.stringValue = mountain.name
            }
            return mountainItem
        }
    }
    private func performQuery(with filter: String?) {
        let mountains = self.mountainsController.filteredMountains(with: filter).sorted { $0.name < $1.name }

        let snapshot = NSDiffableDataSourceSnapshotReference()
        snapshot.appendSections(withIdentifiers: [mainSection])
        snapshot.appendItems(withIdentifiers: mountains)
        dataSource.applySnapshot(snapshot, animatingDifferences: true)
    }
}

extension MountainsWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let contentSize = layoutEnvironment.container.effectiveContentSize
            let columns = contentSize.width > 800 ? 3 : 2
            let spacing = CGFloat(10)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(32))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            return section
        }

        let layout = NSCollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        return layout
    }

    private func configureHierarchy() {
        let itemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        collectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        collectionView.collectionViewLayout = createLayout()
    }
}

extension MountainsWindowController: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        performQuery(with: searchField.stringValue)
    }
}
