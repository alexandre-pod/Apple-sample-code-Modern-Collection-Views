/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`InsertionSortArray` provides a self sorting array class
*/

import Cocoa

class InsertionSortArray: NSObject {

    class SortNode: NSObject {
        let value: Int
        let color: NSColor

        init(value: Int, maxValue: Int) {
            self.value = value
            let hue = CGFloat(value) / CGFloat(maxValue)
            self.color = NSColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        private let identifier = UUID()

        override var hash: Int {
            return identifier.hashValue
        }

        override func isEqual(_ object: Any?) -> Bool {
            guard let otherNode = object as? SortNode else { return false }
            return identifier == otherNode.identifier
        }
    }
    var values: [SortNode] {
        return nodes
    }
    var isSorted: Bool {
        return isSortedInternal
    }
    func sortNext() {
        performNextSortStep()
    }
    init(count: Int) {
        nodes = (0..<count).map { SortNode(value: $0, maxValue: count) }.shuffled()
    }
    override var hash: Int {
        return identifier.hashValue
    }
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherArray = object as? InsertionSortArray else { return false }
        return identifier == otherArray.identifier
    }
    private var identifier = UUID()
    private var currentIndex = 1
    private var isSortedInternal = false
    private var nodes: [SortNode]
}

extension InsertionSortArray {
    fileprivate func performNextSortStep() {
        if isSortedInternal {
            return
        }
        if nodes.count == 1 {
            isSortedInternal = true
            return
        }

        var index = currentIndex
        let currentNode = nodes[index]
        index -= 1
        while index >= 0 && currentNode.value < nodes[index].value {
            let tmp = nodes[index]
            nodes[index] = currentNode
            nodes[index + 1] = tmp
            index -= 1
        }
        currentIndex += 1
        if currentIndex >= nodes.count {
            isSortedInternal = true
        }
    }
}
