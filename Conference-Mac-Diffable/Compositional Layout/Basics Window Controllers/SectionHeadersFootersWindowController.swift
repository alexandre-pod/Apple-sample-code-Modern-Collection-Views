/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A layout that adapts to a changing layout environment
*/

import Cocoa

class SectionHeadersFootersWindowController: NSWindowController {

    static let sectionHeaderElementKind = "section-header-element-kind"
    static let sectionFooterElementKind = "section-footer-element-kind"

    private var dataSource: NSCollectionViewDiffableDataSourceReference! = nil
    @IBOutlet weak var sectionCollectionView: NSCollectionView!

    override func windowDidLoad() {
        super.windowDidLoad()
        configureHierarchy()
        configureDataSource()
    }
}

extension SectionHeadersFootersWindowController {
    private func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SectionHeadersFootersWindowController.sectionHeaderElementKind,
            alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SectionHeadersFootersWindowController.sectionFooterElementKind,
            alignment: .bottom)
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]

        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension SectionHeadersFootersWindowController {
    private func configureHierarchy() {
        let itemNib = NSNib(nibNamed: "TextItem", bundle: nil)
        sectionCollectionView.register(itemNib, forItemWithIdentifier: TextItem.reuseIdentifier)

        let titleSupplementaryNib = NSNib(nibNamed: "TitleSupplementaryView", bundle: nil)
        sectionCollectionView.register(titleSupplementaryNib,
                    forSupplementaryViewOfKind: SectionHeadersFootersWindowController.sectionHeaderElementKind,
                    withIdentifier: TitleSupplementaryView.reuseIdentifier)
        sectionCollectionView.register(titleSupplementaryNib,
                    forSupplementaryViewOfKind: SectionHeadersFootersWindowController.sectionFooterElementKind,
                    withIdentifier: TitleSupplementaryView.reuseIdentifier)

        sectionCollectionView.collectionViewLayout = createLayout()
    }
    private func configureDataSource() {
        dataSource = NSCollectionViewDiffableDataSourceReference(collectionView: sectionCollectionView) {
                (collectionView: NSCollectionView,
                indexPath: IndexPath,
                identifier: Any) -> NSCollectionViewItem? in
                let item = self.sectionCollectionView.makeItem(withIdentifier: TextItem.reuseIdentifier, for: indexPath)
            item.textField?.stringValue = "\(indexPath.section),\(indexPath.item)"
            return item
        }
        dataSource.supplementaryViewProvider = {
            (collectionView: NSCollectionView, kind: String, indexPath: IndexPath) -> NSView? in
            if let supplementaryView = self.sectionCollectionView.makeSupplementaryView(
                ofKind: kind,
                withIdentifier: TitleSupplementaryView.reuseIdentifier,
                for: indexPath) as? TitleSupplementaryView {
                let viewKind = kind == SectionHeadersFootersWindowController.sectionHeaderElementKind ?
                    "Header" : "Footer"
                supplementaryView.label.stringValue = "\(viewKind) for section \(indexPath.section)"
                return supplementaryView
            } else {
                fatalError("Cannot create new supplementary")
            }
        }

        // initial data
        let itemsPerSection = 5
        let sections = Array(0..<5)
        let snapshot = NSDiffableDataSourceSnapshotReference()
        var itemOffset = 0
        sections.forEach {
            snapshot.appendSections(withIdentifiers: [NSNumber(value: $0)])
            snapshot.appendItems(withIdentifiers: Array(itemOffset..<itemOffset + itemsPerSection).map {
                NSNumber(value: $0)
            })
            itemOffset += itemsPerSection
        }
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
    }
}
