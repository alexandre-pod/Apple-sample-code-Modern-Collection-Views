/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Mimics the iOS Wi-Fi settings UI for displaying a dynamic list of available wi-fi access points
*/

import Cocoa

class WiFiSettingsWindowController: NSWindowController {

    // For now, section and item identifiers must be class types that hash
    // and compare as Objective-C NSObjects on macOS, or else you must maintain
    // pointer identity for each given section and item.  These section and
    // item types are used with "Reference" variants of the DiffableDataSource API.
    // Anticipated Swift overlay support will allow native Swift objects and value
    // types to be used along with the regular DiffableDataSource classes instead.

    enum Kind: Int {
        case config
        case networks
    }

    class Section: NSObject {

        let kind: Kind

        init(_ kind: Kind) {
            self.kind = kind
        }

        override var hash: Int {
            return kind.rawValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let section = object as? Section else { return false }
            return kind == section.kind
        }
    }

    enum ItemType {
        case wifiEnabled, currentNetwork, availableNetwork
    }

    class Item: NSObject {
        let title: String
        let type: ItemType
        let network: WIFIController.Network?

        init(title: String, type: ItemType) {
            self.title = title
            self.type = type
            self.network = nil
            self.identifier = UUID()
        }
        init(network: WIFIController.Network) {
            self.title = network.name
            self.type = .availableNetwork
            self.network = network
            self.identifier = network.identifier
        }
        var isConfig: Bool {
            let configItems: [ItemType] = [.currentNetwork, .wifiEnabled]
            return configItems.contains(type)
        }
        var isNetwork: Bool {
            return type == .availableNetwork
        }

        let identifier: UUID

        override var hash: Int {
            return identifier.hashValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let item = object as? Item else { return false }
            return identifier == item.identifier
        }
    }

    @IBOutlet weak var collectionView: NSCollectionView! = nil
    private var dataSource: NSCollectionViewDiffableDataSourceReference<Section, Item>! = nil
    private var currentSnapshot: NSDiffableDataSourceSnapshotReference<Section, Item>! = nil
    private var wifiController: WIFIController! = nil
    private lazy var configurationItems: [Item] = {
        return [Item(title: "Wi-Fi", type: .wifiEnabled),
                Item(title: "breeno-net", type: .currentNetwork)]
    }()

    static let reuseIdentifier = NSUserInterfaceItemIdentifier("reuse-identifier")

    override func windowDidLoad() {
        super.windowDidLoad()
        configureCollectionView()
        configureDataSource()
        updateUI(animated: false)
    }

    func configureCollectionView() {
        let itemNib = NSNib(nibNamed: "WiFiNetworkItem", bundle: nil)!
        collectionView.register(itemNib, forItemWithIdentifier: WiFiNetworkItem.reuseIdentifier)
        collectionView.collectionViewLayout = createLayout()
    }
}

extension WiFiSettingsWindowController {

    private func configureDataSource() {

        wifiController = WIFIController { [weak self] (controller: WIFIController) in
            guard let self = self else { return }
            self.updateUI()
        }

        dataSource = NSCollectionViewDiffableDataSourceReference<Section, Item>(collectionView: collectionView,
                                                                                itemProvider: {
            (collectionView: NSCollectionView, indexPath: IndexPath, item: Item) -> NSCollectionViewItem? in
            guard let collectionViewItem = collectionView.makeItem(
                withIdentifier: WiFiNetworkItem.reuseIdentifier,
                for: indexPath) as? WiFiNetworkItem else { fatalError() }

            collectionViewItem.textField?.stringValue = item.title

            // network cell
            if item.isNetwork {
                collectionViewItem.imageView?.isHidden = true
                collectionViewItem.textField?.isHidden = false
                collectionViewItem.checkBox.isHidden = true
            // configuration cells
            } else if item.isConfig {
                if item.type == .wifiEnabled {
                    collectionViewItem.textField?.stringValue = "Wi-Fi Enabled"
                    collectionViewItem.checkBox.target = self
                    collectionViewItem.checkBox.action = #selector(self.toggleWifi(_:))
                    collectionViewItem.checkBox.state = self.wifiController.wifiEnabled ? .on : .off
                    collectionViewItem.checkBox.isHidden = false
                    collectionViewItem.imageView?.isHidden = true
                    collectionViewItem.textField?.isHidden = false
                } else {
                    collectionViewItem.imageView?.isHidden = false
                    collectionViewItem.checkBox.isHidden = true
                    collectionViewItem.textField?.isHidden = false
                }
            } else {
                fatalError("Unknown item type!")
            }

            return collectionViewItem
        })
    }

    private func updateUI(animated: Bool = true) {
        guard let controller = self.wifiController else { return }
        let configItems = configurationItems.filter { !($0.type == .currentNetwork && !controller.wifiEnabled) }
        let sortedNetworks = controller.availableNetworks.sorted { $0.name < $1.name }
        let networkItems = sortedNetworks.map { Item(network: $0) }

        currentSnapshot = NSDiffableDataSourceSnapshotReference<Section, Item>()

        let configSection = Section(.config)
        currentSnapshot.appendSections(withIdentifiers: [configSection])
        currentSnapshot.appendItems(withIdentifiers: configItems, intoSectionWithIdentifier: configSection)

        if controller.wifiEnabled {
            let networkSection = Section(.networks)
            currentSnapshot.appendSections(withIdentifiers: [networkSection])
            currentSnapshot.appendItems(withIdentifiers: networkItems, intoSectionWithIdentifier: networkSection)
        }

        self.dataSource.applySnapshot(currentSnapshot, animatingDifferences: animated)
    }

    private func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(19))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 5
        section.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10)

        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }

    @IBAction func toggleWifi(_ wifiEnabledCheckBox: NSButton) {
        wifiController.wifiEnabled = wifiEnabledCheckBox.state == .on
        updateUI()
    }
}
